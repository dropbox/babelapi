//
//  Dropbox.swift
//  Dropbox
//
//  Created by Leah Culver on 10/9/14.
//  Copyright (c) 2014 Dropbox. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// Dropbox API errors
public let DropboxErrorDomain = "com.dropbox.error"

public class Box<T> {
	public let unboxed : T
	init (_ v : T) { self.unboxed = v }
}
public enum CallError<ErrorType> {
    case InternalServerError(Int, String?)
    case BadInputError(String?)
    case RateLimitError
    case HTTPError(Int?, String?)
    case RouteError(Box<ErrorType>)
}



public class DropboxClient {
    var accessToken: String
    var baseHosts : [String : String]
    
    public init(accessToken: String, baseApiUrl: String, baseContentUrl: String, baseNotifyUrl: String) {
        self.accessToken = accessToken
        self.baseHosts = [
            "meta" : baseApiUrl,
            "content": baseContentUrl,
            "notify": baseNotifyUrl,
        ]
        
        // Authentication header with access token
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Authorization" : "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
    }
    
    public convenience init(accessToken: String) {
        self.init(accessToken: accessToken,
            baseApiUrl: "https://api.dropbox.com/2-beta",
            baseContentUrl: "https://api-content.dropbox.com",
            baseNotifyUrl: "https://api-notify.dropbox.com")
    }
    
    
    func runRequest<RType: JSONSerializer, EType: JSONSerializer>(
        #host: String,
        route: String,
        params: String?,
        responseSerializer: RType,
        errorSerializer: EType,
        completionHandler: (RType.ValueType?, CallError<EType.ValueType>?) -> Void) {
            let url = "\(self.baseHosts[host]!)\(route)"
            Alamofire.request(.POST, url, parameters: [:], encoding: .Custom({convertible, _ in
                var mutableRequest = convertible.URLRequest.copy() as NSMutableURLRequest
                if params != nil {
                    mutableRequest.HTTPBody = params!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                }
                return (mutableRequest, nil)
            })).validate()
                .response { (request, response, data, error) -> Void in
                    var err : CallError<EType.ValueType>?
					var ret : RType.ValueType?
                    if error != nil {
                        if let code = response?.statusCode {
                            switch code {
                            case 500...599:
                                let message = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)
                                err = .InternalServerError(code, message)
                            case 400:
                                let message = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)
                                err = .BadInputError(message)
                            case 429:
                                err = .RateLimitError
                            case 409:
                                let json = JSON(data: data as NSData)
                                err = .RouteError(Box(errorSerializer.deserialize(json)))
                            default:
                                err = .HTTPError(code, "An error occurred.")
                            }
                        } else {
                            let message = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)
                            err = .HTTPError(nil, message)
                        }
                    } else {
                        ret = responseSerializer.deserialize(JSON(data: data as NSData))
                    }
                    completionHandler(ret, err)
            }

    }
}





