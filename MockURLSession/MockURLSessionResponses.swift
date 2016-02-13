//
//  MockURLSession.swift
//  MockURLSession
//
//  Created by Jed Lewison on 2/12/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public class MockResponseValues: NSObject {

    public let request: NSURLRequest

    public var statusCode = 200
    public var headerFields: [String : String] = [ : ]
    public var HTTPVersion: String? = nil
    public var URL: NSURL
    private var data: NSData? = nil
    public var userInfo: [NSObject : AnyObject]? = [ : ]

    @objc(setDataWithData:)
    public func setData(withData data: NSData) {
        self.data = data
    }

    @objc(setDataWithString:)
    public func setData(withString string: String) {
        setData(withString: string, encoding: NSUTF8StringEncoding)
    }

    @objc(setDataWithString:encoding:)
    public func setData(withString string: String, encoding: NSStringEncoding) {
        self.data = string.dataUsingEncoding(encoding)
    }

    @objc(setDataWithJSON:)
    public func setData(withJSON JSON: AnyObject) {
        self.data = try? NSJSONSerialization.dataWithJSONObject(JSON, options: [.PrettyPrinted])
    }

    @objc(setDataWithPropertyList:)
    public func setData(withPropertyList plist: AnyObject) {
        self.data = try? NSPropertyListSerialization.dataWithPropertyList(plist, format: .XMLFormat_v1_0, options: 0)
    }

    private init?(request: NSURLRequest) {
        self.request = request
        self.URL = request.URL ?? NSURL()
        super.init()
        if request.URL == nil { return nil }
    }

    private func representedCachedURLResponse() -> NSCachedURLResponse? {
        guard let response = NSHTTPURLResponse(URL: URL, statusCode: statusCode, HTTPVersion: HTTPVersion, headerFields: headerFields) else { return nil }
        return NSCachedURLResponse(response: response, data: data ?? NSData(), userInfo: userInfo, storagePolicy: .AllowedInMemoryOnly)
    }
}

public protocol MockURLSessionResponding: class {
    func finalizeMockResponseValuesForRequest(initialValues: MockResponseValues)
}

public class MockURLSession: NSObject {

    public static let sharedInstance = MockURLSession()

    public weak var dataSource: MockURLSessionResponding?

    public func cachedResponseForDataTask(dataTask: NSURLSessionDataTask) -> NSCachedURLResponse? {
        guard let request = dataTask.originalRequest,
            mockResponseValues = MockResponseValues(request: request) else { return nil }
        dataSource?.finalizeMockResponseValuesForRequest(mockResponseValues)
        return mockResponseValues.representedCachedURLResponse()
    }

}
