import Foundation
import Alamofire

public class Client {
    let manager: Alamofire.Manager

    public init(accessToken: String) {
        var mutableHTTPAdditionalHeaders: [NSObject: AnyObject] = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders!
        mutableHTTPAdditionalHeaders["Authorization"] = "Bearer \(accessToken)"

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = mutableHTTPAdditionalHeaders

        manager = Alamofire.Manager(configuration: configuration)
    }

    deinit {
        manager.session.invalidateAndCancel()
    }
}

// MARK: -

public enum Result<T> {
    case Success(T)
    case Failure
}

public protocol ResponseResultSerializable {
    init(response: NSHTTPURLResponse, representation: NSDictionary)
}

extension Alamofire.Request {
    public func responseResult<T: ResponseResultSerializable>(completionHandler: (Result<T>) -> Void) -> Self {
        return responseString { (request, response, string, error) in
            println(request)
            println(response)
            println(string)
            println(error)
        }.response(serializer: Alamofire.Request.responseDataSerializer(), completionHandler: { (request, response, data, error) in
            if error != nil || response == nil || data == nil {
                completionHandler(Result<T>.Failure)
            } else {
                if let representation = NSJSONSerialization.JSONObjectWithData(data as NSData, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                    let object = T(response: response!, representation: representation)
                    completionHandler(Result<T>.Success(object))
                } else {
                    completionHandler(Result<T>.Failure)
                }
            }
        })
    }
}