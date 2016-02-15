//
//  NetworkModel.swift
//  Interceptor
//
//  Created by Jed Lewison on 2/12/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import Alamofire


class SillyNetworkModel {

    var requestResult: String?
    var error: ErrorType?

    func startAlamofire(url: NSURL) {

                Alamofire.request(NSURLRequest(URL: url)).responseString { (response) -> Void in
        
                    print("*******************************", __FUNCTION__)
        
                    switch response.result {
                    case .Failure(let error):
                        self.error = error
                    case .Success(let value):
                        self.requestResult = value
                    }
                }

    }

    func startURLRequest(url: NSURL) {

        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) {
            responses in
            if let data = responses.0 {
                self.requestResult = String(data: data, encoding: NSUTF8StringEncoding)
            }
            self.error = responses.2
        }

        dataTask.resume()
    }

    func startURL(url: NSURL) {

        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url) {
            responses in
            if let data = responses.0 {
                self.requestResult = String(data: data, encoding: NSUTF8StringEncoding)
            }
            self.error = responses.2
        }

        dataTask.resume()
    }
}