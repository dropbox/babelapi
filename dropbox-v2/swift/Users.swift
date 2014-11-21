import Foundation

typealias AccountID = String
// TODO: (mattt) Be more clever about StringLiteralConvertible struct that asserts length constraints?

/// The space quota info for a user.
struct Space {
    /// The user's total quota allocation (bytes).
    let quota: UInt64

    /// The user's used quota outside of shared folders (bytes).
    // NOTE: Reserved keywords must be escaped with backticks.
    let `private`: UInt64

    /// The user's used quota in shared folders (bytes).
    let shared: UInt64

    /// The user's used quota in datastores (bytes).
    let datastores: UInt64
}

// NOTE: Examples are implemented here as static constructors, but would be more appropriate as test fixtures
extension Space {
    static func example() -> Space {
        return Space(quota: 1000000, `private`: 1000, shared: 500, datastores: 42)
    }
}

// MARK: -

/// Information about a team.
struct Team {
    /// The team's unique ID.
    let id: String

    /// The name of the team.
    let name: String
}

extension Team {
    static func example() -> Team {
        return Team(id: "dbtid:AAFdgehTzw7WlXhZJsbGCLePe8RvQGYDr-I", name: "Acme, Inc.")
    }
}

// MARK: -

/// Contains several ways a name might be represented to make internationalization more convenient.
struct Name {
    /// Also known as a first name.
    let givenName: String

    /// Also known as a last name or family name.
    let surname: String

    /// Locale-dependent familiar name. Generally matches :field:`given_name` or :field:`display_name`.
    let familiarName: String

    /// A name that can be used directly to represent the name of a user's Dropbox account.
    let displayName: String
}

extension Name {
    static func example() -> Name {
        return Name(givenName: "Franz", surname: "Ferdinand", familiarName: "Franz Ferdinand", displayName: "Franz Ferdinand (Personal)")
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
struct BasicAccountInfo {
    /// The user's unique Dropbox ID.
    let accountID: AccountID

    /// Details of a user's name.
    let name: Name
}

/// Information about a user's account.
struct MeInfo {
    /// The user's unique Dropbox ID.
    let accountID: AccountID

    /// Details of a user's name.
    let name: Name

    /// The user's e-mail address.
    let email: String

    /// The user's two-letter country code, if available.
    // NOTE: Documentation should be specific about being ISO 3166-1 codes
    let country: String?

    /// The language setting that user specified.
    // NOTE: Documentation is unclear; is this ISO 639 language code or IETF / BCP 47 language tag?
    let locale: String

    /// The user's :link:`referral link https://www.dropbox.com/referrals`.
    let referralLink: String

    /// The user's quota.
    let space: Space

    /// If this account is a member of a team.
    let team: Team?

    /// Whether the user has a personal and work account. If the authorized account is personal, then :field:`team` will always be :val:`Null`, but :field:`is_paired` will indicate if a work account is linked.
    let isPaired: Bool
}

extension MeInfo {
    static func example() -> MeInfo {
        return MeInfo(accountID: "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc", name: Name.example(), email: "franz@dropbox.com", country: "US", locale: "en", referralLink: "https://db.tt/ZITNuhtI", space: Space.example(), team: Team.example(), isPaired: true)
    }
}

// MARK: - Router

extension Router {
    enum Users {
        ///
        case Info(accountId: AccountID)

        ///
        case InfoMe
    }
}

// MARK: - Client

extension Client {
    /// Get information about a user's account.
    func getInfo(accountID: AccountID, completionHandler: (Result<BasicAccountInfo>) -> Void) {
        // ...
    }

    /// Get information about the authorized user's account.
    func getInfoMe(completionHandler: (Result<MeInfo>) -> Void) {
        // ...
    }
}
