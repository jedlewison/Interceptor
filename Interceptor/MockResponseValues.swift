//
//  Interceptor.swift
//  Interceptor
//
//  Created by Jed Lewison on 2/12/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

/// `MockResponseValues` is a mutable object encapsulating the values necessary to construct a
/// mock URL response for unit tests.
///
/// You don't create a `MockResponseValues` directly. Instead, you receive one as a dataSource for a
/// `Interceptor` when it needs to provide a mock response to an `NSURLRequest`.
///
public class MockResponseValues: NSObject {

    public let request: NSURLRequest

    public var statusCode = 200
    public var headerFields: [String : String] = [ : ]
    public var HTTPVersion: String? = nil
    public var URL: NSURL
    public var userInfo: [NSObject : AnyObject]? = [ : ]

    public var data: NSData? = nil

    public init?(request: NSURLRequest) {
        self.request = request
        self.URL = request.URL ?? NSURL()
        super.init()
        if request.URL == nil { return nil }
    }
}

// MARK: Setting response data
public extension MockResponseValues {

    /// Set mock response's data
    @objc(setDataWithData:)
    public func setData(withData data: NSData) {
        self.data = data
    }

    /// Set mock response's data to a data representation of the string encoded using `NSUTF8StringEncoding` encoding
    @objc(setDataWithString:)
    public func setData(withString string: String) {
        setData(withString: string, encoding: NSUTF8StringEncoding)
    }

    /// Set mock response's data to a data representation of the string encoded using a given encoding
    @objc(setDataWithString:encoding:)
    public func setData(withString string: String, encoding: NSStringEncoding) {
        self.data = string.dataUsingEncoding(encoding)
    }

    /// Set mock response's data to a data representation of the string encoded using a given encoding
    @objc(withContentsOfResource:withExtension:)
    public func setData(withContentsOfResource name: String, withExtension ext: String) {
        let bundle = NSBundle(forClass: self.classForCoder)
        if let url = bundle.URLForResource(name, withExtension: ext) {
            self.data = NSData(contentsOfURL: url)
        }
    }

    /// Set mock response's data to a data representation of the JSON object.
    @objc(setDataWithJSON:error:)
    public func setData(withJSON JSON: AnyObject) throws {
        self.data = try NSJSONSerialization.dataWithJSONObject(JSON, options: [.PrettyPrinted])
    }

    /// Set mock response's data to a data representation of the plist object.
    @objc(setDataWithPropertyList:error:)
    public func setData(withPropertyList plist: AnyObject) throws {
        self.data = try NSPropertyListSerialization.dataWithPropertyList(plist, format: .XMLFormat_v1_0, options: 0)
    }
}

extension MockResponseValues {

    func representedCachedURLResponse() -> NSCachedURLResponse? {
        guard let response = NSHTTPURLResponse(URL: URL, statusCode: statusCode, HTTPVersion: HTTPVersion, headerFields: headerFields) else { return nil }
        return NSCachedURLResponse(response: response, data: data ?? NSData(), userInfo: userInfo, storagePolicy: .AllowedInMemoryOnly)
    }
}
