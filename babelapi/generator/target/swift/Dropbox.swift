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
public enum RequestResult<ResponseType, ErrorType> {
    case InternalServerError(Int, String?)
    case BadInputError(String?)
    case RateLimitError
    case HTTPError(Int?, String?)
    case RouteError(ErrorType)
    case RouteResult(ResponseType)
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
            baseApiUrl: "https://api.dropbox.com/2/",
            baseContentUrl: "https://api-content.dropbox.com",
            baseNotifyUrl: "https://api-notify.dropbox.com")
    }
    
    
    func runRequest<RType: JSONSerializer, EType: JSONSerializer>(
        #host: String,
        route: String,
        params: String?,
        responseSerializer: RType,
        errorSerializer: EType,
        completionHandler: RequestResult<RType.ValueType, EType.ValueType> -> Void) {
            let url = "\(self.baseHosts[host]!)/\(route)"
            let manager = Alamofire.Manager.sharedInstance
            var req = NSMutableURLRequest(URL: NSURL(string: url)!)

            if let p = params {
                req.HTTPBody = p.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            }
            
            manager.request(req)
                .validate()
                .response { (request, response, data, error) -> Void in
                    var ret : RequestResult<RType.ValueType, EType.ValueType>
                    if error != nil {
                        if let code = response?.statusCode {
                            switch code {
                            case 500...599:
                                let message = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)
                                ret = .InternalServerError(code, message)
                            case 400:
                                let message = NSString(data: data as NSData, encoding: NSUTF8StringEncoding)
                                ret = .BadInputError(message)
                            case 429:
                                ret = .RateLimitError
                            case 409:
                                ret = .RouteError(errorSerializer.deserialize(JSON(data as NSData)))
                            default:
                                ret = .HTTPError(code, "An error occurred.")
                            }
                        } else {
                            ret = .HTTPError(nil, nil)
                        }
                    } else {
                        ret = .RouteResult(responseSerializer.deserialize(JSON(data as NSData)))
                    }
                    completionHandler(ret)
            }
    }
}
