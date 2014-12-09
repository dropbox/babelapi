import Foundation
import Alamofire

public typealias AccountID = String
// TODO: (mattt) Be more clever about StringLiteralConvertible struct that asserts length constraints?

/// The space quota info for a user.
public struct Space {
    /// The user's total quota allocation (bytes).
    public let quota: UInt64

    /// The user's used quota outside of shared folders (bytes).
    // NOTE: Reserved keywords must be escaped with backticks.
    public let `private`: UInt64

    /// The user's used quota in shared folders (bytes).
    public let shared: UInt64

    /// The user's used quota in datastores (bytes).
    public let datastores: UInt64

    public init(quota: UInt64, `private`: UInt64, shared: UInt64, datastores: UInt64) {
        self.quota = quota
        self.`private` = `private`
        self.shared = shared
        self.datastores = datastores
    }
}

// MARK: -

/// Information about a team.
public struct Team {
    /// The team's unique ID.
    public let id: String

    /// The name of the team.
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: -

/// Contains several ways a name might be represented to make internationalization more convenient.
public struct Name {
    /// Also known as a first name.
    public let givenName: String

    /// Also known as a last name or family name.
    public let surname: String

    /// Locale-dependent familiar name. Generally matches :field:`given_name` or :field:`display_name`.
    public let familiarName: String

    /// A name that can be used directly to represent the name of a user's Dropbox account.
    public let displayName: String

    public init(givenName: String, surname: String, familiarName: String, displayName: String) {
        self.givenName = givenName
        self.surname = surname
        self.familiarName = familiarName
        self.displayName = displayName
    }
}

// MARK: -

/*
// Because Swift structs do not support inheritence, Babel struct extensions can be implemented in a few different ways.
// The simplest way would be to logically resolve the struct extension at generation, duplicating the inherited member declarations. The downside to this approach is type erasure: BasicAccountInfo and MeInfo types are unrelated.
// To preserve this type relationship, an intermediary protocol (`AccountInfo` or even `BasicAccountInfo`) could be used:

protocol AccountInfo {
    var accountID: AccountID { get }
    var name: Name { get }
}

/// Basic information about a user's account.
struct BasicAccountInfo: AccountInfo {
    /// The user's unique Dropbox ID.
    let accountID: AccountID

    /// Details of a user's name.
    let name: Name
}

/// Information about a user's account.
struct MeInfo: AccountInfo {
    /// The user's unique Dropbox ID.
    let accountID: AccountID

    /// Details of a user's name.
    let name: Name

    // ...
}
*/

/// Basic information about a user's account.
public struct BasicAccountInfo {
    /// The user's unique Dropbox ID.
    public let accountID: AccountID

    /// Details of a user's name.
    public let name: Name
}

/// Information about a user's account.
public struct MeInfo {
    /// The user's unique Dropbox ID.
    public let accountID: AccountID

    /// Details of a user's name.
    public let name: Name

    /// The user's e-mail address.
    public let email: String

    /// The user's two-letter country code, if available.
    // NOTE: Documentation should be specific about being ISO 3166-1 codes
    public let country: String?

    /// The language setting that user specified.
    // NOTE: Documentation is unclear; is this ISO 639 language code or IETF / BCP 47 language tag?
    public let locale: String

    /// The user's :link:`referral link https://www.dropbox.com/referrals`.
    public let referralLink: String

    /// The user's quota.
    public let space: Space

    /// If this account is a member of a team.
    public let team: Team?

    /// Whether the user has a personal and work account. If the authorized account is personal, then :field:`team` will always be :val:`Null`, but :field:`is_paired` will indicate if a work account is linked.
    public let isPaired: Bool

    public init(accountID: AccountID, name: Name, email: String, country: String?, locale: String, referralLink: String, space: Space, team: Team?, isPaired: Bool) {
        self.accountID = accountID
        self.name = name
        self.email = email
        self.country = country
        self.locale = locale
        self.referralLink = referralLink
        self.space = space
        self.team = team
        self.isPaired = isPaired
    }
}

public enum AccountInfo {
    case Me(MeInfo)
    case Teammate(BasicAccountInfo)
    case User(BasicAccountInfo)
}

// MARK: - ResponseResultSerializable

extension Space: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        self.quota = UInt64(representation["quota"]!.integerValue)
        self.`private` = UInt64(representation["private"]!.integerValue)
        self.shared = UInt64(representation["shared"]!.integerValue)
        self.datastores = UInt64(representation["datastores"]!.integerValue)
    }
}

extension Team: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        self.id = representation["id"] as String
        self.name = representation["name"] as String
    }
}

extension Name: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        self.givenName = representation["given_name"] as String
        self.surname = representation["surname"] as String
        self.familiarName = representation["familiar_name"] as String
        self.displayName = representation["display_name"] as String
    }
}

extension BasicAccountInfo: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        self.accountID = representation["account_id"] as String
        self.name = Name(response: response, representation: representation["name"] as NSDictionary)!
    }
}

extension MeInfo: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        self.accountID = representation["account_id"] as String
        self.name = Name(response: response, representation: representation["name"] as NSDictionary)!
        self.email = representation["email"] as String
        self.country = representation["country"] as? String
        self.locale = representation["locale"] as String
        self.referralLink = representation["referral_link"] as String
        self.space = Space(response: response, representation: representation["space"] as NSDictionary)!
        if !(representation["team"] is NSNull) {
            self.team = Team(response: response, representation: representation["team"] as NSDictionary)!
        }
        self.isPaired = representation["is_paired"]!.boolValue!
    }
}

extension AccountInfo: ResponseResultSerializable {
    public init?(response: NSHTTPURLResponse, representation: NSDictionary) {
        if let me = representation["me"] as? NSDictionary {
            if let meInfo = MeInfo(response: response, representation: me) {
                self = .Me(meInfo)
            } else {
                return nil
            }
        } else if let meInfo = MeInfo(response: response, representation: representation) {
            self = .Me(meInfo)
        } else if let teammate = representation["teammate"] as? NSDictionary {
            if let teamInfo = BasicAccountInfo(response: response, representation: teammate) {
                self = .Teammate(teamInfo)
            } else {
                return nil
            }
        } else if let user = representation["user"] as? NSDictionary {
            if let userInfo = BasicAccountInfo(response: response, representation: user) {
                self = .User(userInfo)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: - Router

extension Router {
    public enum Users {
        ///
        case Info(accountId: AccountID)

        ///
        case InfoMe
    }
}

extension Router.Users: URLStringConvertible, URLRequestConvertible {
    public var URLString: String {
        switch self {
        case .Info(accountId: let accountId):
            return Router.baseURL.URLByAppendingPathComponent("users/info/").absoluteString!
        case .InfoMe:
            return Router.baseURL.URLByAppendingPathComponent("users/info/me").absoluteString!
        }
    }

    public var URLRequest: NSURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        mutableURLRequest.HTTPMethod = "POST"

        var parameters: [String: AnyObject]? = nil

        switch self {
        case .Info(accountId: let accountId):
            parameters = ["account_id": accountId]
        default:
            parameters = [:]
        }

        return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
    }
}

// MARK: - Client

extension Client {
    /// Get information about a user's account.
    public func getInfo(accountId: AccountID, completionHandler: (Result<AccountInfo>) -> Void) {
        manager.request(Router.Users.Info(accountId: accountId))
            .validate()
            .responseResult(completionHandler)
    }

    /// Get information about the authorized user's account.
    public func getInfoMe(completionHandler: (Result<AccountInfo>) -> Void) {
        manager.request(Router.Users.InfoMe)
            .validate()
            .responseResult(completionHandler)
    }
}
