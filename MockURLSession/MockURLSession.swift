//
//  MockURLSession.swift
//  MockURLSession
//
//  Created by Jed Lewison on 2/13/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

/// `MockURLSessionResponding` defines the protocol through which test classes can set values of mock responses.
public protocol MockURLSessionResponding: class {

    /// Just before providing a mock response, the `MockURLSession` calls
    /// `finalizeMockResponseValuesForRequest:` with a `MockResponseValues` configured to default values.
    ///
    /// This is your opportunity to finalize the response, providing custom data, headers, status code, etc.
    /// You do this by setting `MockResponseValues` properties. `MockURLSession` will then use these values to
    /// generate the appropriate NSURLResponse and NSData.
    func finalizeMockResponseValuesForRequest(initialValues: MockResponseValues)
}

/// `MockURLSession` provides the mock responses for NSURLSessionDataTask requests and provides the
/// `MockURLSessionResponding` protocol for customizing those responses.
final public class MockURLSession: NSObject {

    public static let sharedInstance = MockURLSession()

    /// A test class should set itself to be the datasource of the shared `MockURLSession` instance during test setup.
    public weak var dataSource: MockURLSessionResponding?

    /// You should never need to use this function. It is an implementation detail. However, you can override it
    /// if you want to build your own mechanism for delivering mock url responses. Be careful not to cancel,
    /// resume, or suspend the dataTask. Use it only to identify the original request.
    public func cachedResponseForDataTask(dataTask: NSURLSessionDataTask) -> NSCachedURLResponse? {
        guard let request = dataTask.originalRequest,
            mockResponseValues = MockResponseValues(request: request) else { return nil }
        dataSource?.finalizeMockResponseValuesForRequest(mockResponseValues)
        return mockResponseValues.representedCachedURLResponse()
    }
    
}