import Foundation
import Alamofire

class Client {
    let manager: Alamofire.Manager

    init() {
        manager = Alamofire.Manager.sharedInstance
    }
}

// MARK: -

enum Result<T> {
    case Success(T)
    case Failure
}

protocol ResponseResultSerializable {
    init(response: NSHTTPURLResponse, representation: [String: Any])
}

extension Alamofire.Request {
    func responseResult<T: ResponseResultSerializable>(completionHandler: (Result<T>) -> Void) -> Self {
        return response(serializer: Alamofire.Request.responseDataSerializer(), completionHandler: { (request, response, data, error) in
            if error != nil || response == nil || data == nil {
                completionHandler(Result<T>.Failure)
            } else {
                // TODO: Add JSON parsing to convert data to representation
//                var error: NSError
//                let representation = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                let object = T(response: response!, representation: [:])
                completionHandler(Result<T>.Success(object))
            }
        })
    }
}