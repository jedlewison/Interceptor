//
//  NSURLSession+Swizzling.m
//  MockURLSession
//
//  Created by Jed Lewison on 2/12/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

#import "NSURLSession+Swizzling.h"
#import <MockURLSession/MockURLSession-Swift.h>
@import ObjectiveC;

@implementation NSURLSession (Swizzling)

+ (void)exchangeImplementationOfSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {

    Class class = [self class];

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

}

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [self exchangeImplementationOfSelector:@selector(dataTaskWithRequest:)
                                  withSelector:@selector(mush_dataTaskWithRequest:)];

        [self exchangeImplementationOfSelector:@selector(dataTaskWithRequest:completionHandler:)
                                  withSelector:@selector(mush_dataTaskWithRequest:completionHandler:)];

        [self exchangeImplementationOfSelector:@selector(dataTaskWithURL:)
                                  withSelector:@selector(mush_dataTaskWithURL:)];

        [self exchangeImplementationOfSelector:@selector(dataTaskWithURL:completionHandler:)
                                  withSelector:@selector(mush_dataTaskWithURL:completionHandler:)];

    });
    
}

#pragma mark - Method Swizzling

- (NSURLSessionDataTask *)mush_dataTaskWithRequest:(NSURLRequest *)request {
    NSURLSessionDataTask *dataTask = [self mush_dataTaskWithRequest:[self mush_makeRequestCacheOnly:request]];
    [self mush_storeCachedResponseForDataTask:dataTask];
    return dataTask;
}

- (NSURLSessionDataTask *)mush_dataTaskWithRequest:(NSURLRequest *)request
                                 completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLSessionDataTask *dataTask = [self mush_dataTaskWithRequest:[self mush_makeRequestCacheOnly:request]
                                                  completionHandler:completionHandler];
    [self mush_storeCachedResponseForDataTask:dataTask];
    return dataTask;
}

- (NSURLSessionDataTask *)mush_dataTaskWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                         timeoutInterval:0];
    return [self dataTaskWithRequest:request];
}

- (NSURLSessionDataTask *)mush_dataTaskWithURL:(NSURL *)url
                             completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                         timeoutInterval:0];
    return [self dataTaskWithRequest:request
                   completionHandler:completionHandler];
}

#pragma mark - Mock requests

- (void)mush_storeCachedResponseForDataTask:(NSURLSessionDataTask *)dataTask {
    NSCachedURLResponse *generatedCachedResponse = [[MockURLSession sharedInstance] cachedResponseForDataTask:dataTask];
    [self.configuration.URLCache storeCachedResponse:generatedCachedResponse forDataTask:dataTask];
    [self.configuration.URLCache storeCachedResponse:generatedCachedResponse forRequest:dataTask.originalRequest];
}

- (NSURLRequest *)mush_makeRequestCacheOnly:(NSURLRequest *)request {
    [self.configuration setRequestCachePolicy:NSURLRequestReturnCacheDataDontLoad];
    if (request.cachePolicy == NSURLRequestReturnCacheDataDontLoad && request.timeoutInterval == 0) {
        return request;
    } else {
        if (![request isKindOfClass:[NSMutableURLRequest class]]) {
            request = [request mutableCopy];
        }
        [(NSMutableURLRequest *)request setTimeoutInterval:0];
        [(NSMutableURLRequest *)request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        return request;
    }
}

@end