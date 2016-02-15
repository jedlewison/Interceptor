//
//  Interceptor.swift
//  Interceptor
//
//  Created by Jed Lewison on 2/13/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import ObjectiveC

func synchronized<ReturnType>(lockToken: AnyObject, @noescape action: () -> ReturnType) -> ReturnType {
    objc_sync_enter(lockToken)
    let result = action()
    objc_sync_exit(lockToken)
    return result
}

/// `InterceptorResponding` defines the protocol through which test classes can set values of mock responses.
public protocol InterceptorResponding: class {

    /// Just before providing a mock response, the `InterceptorSession` calls
    /// `finalizeMockResponseValues(_:forRequest:)` with a `MockResponseValues` configured to default values.
    ///
    /// This is your opportunity to finalize the response, providing custom data, headers, status code, etc.
    /// You do this by setting `MockResponseValues` properties. `InterceptorSession` will then use these values to
    /// generate the appropriate NSURLResponse and NSData.
    func finalizeMockResponseValues(initialValues: MockResponseValues, forRequest request: NSURLRequest)
}

/// `InterceptorSession` provides the mock responses for NSURLSessionDataTask requests and provides the
/// `InterceptorSessionResponding` protocol for customizing those responses.
final public class InterceptorSession: NSObject {

    public static let sharedInstance = InterceptorSession()

    public var active: Bool {
        get {
            return synchronized(self) {
                return _active
            }
        }

        set {
            synchronized(self) {
                _active = newValue
            }
        }
    }

    private var _active: Bool = true
    /// A test class should set itself to be the datasource of the shared `InterceptorSession` instance during test setup.
    public weak var dataSource: InterceptorResponding?

    /// You should never need to use this function. It is an implementation detail. However, you can override it
    /// if you want to build your own mechanism for delivering mock url responses. Be careful not to cancel,
    /// resume, or suspend the dataTask. Use it only to identify the original request.
    public func cachedResponseForDataTask(dataTask: NSURLSessionDataTask) -> NSCachedURLResponse? {
        guard let request = dataTask.originalRequest,
            mockResponseValues = MockResponseValues(request: request) else { return nil }
        dataSource?.finalizeMockResponseValues(mockResponseValues, forRequest: request)
        return mockResponseValues.representedCachedURLResponse()
    }
    
}