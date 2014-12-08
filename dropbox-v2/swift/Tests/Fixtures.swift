import Foundation
import Dropbox

extension Dropbox.Team {
    static func example() -> Dropbox.Team {
        return Dropbox.Team(id: "dbtid:AAFdgehTzw7WlXhZJsbGCLePe8RvQGYDr-I", name: "Acme, Inc.")
    }
}

extension Name {
    static func example() -> Name {
        return Name(givenName: "Franz", surname: "Ferdinand", familiarName: "Franz Ferdinand", displayName: "Franz Ferdinand (Personal)")
    }
}

extension Dropbox.Space {
    static func example() -> Space {
        return Dropbox.Space(quota: 1000000, `private`: 1000, shared: 500, datastores: 42)
    }
}

extension Dropbox.MeInfo {
    static func example() -> MeInfo {
        return Dropbox.MeInfo(accountID: "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc", name: Dropbox.Name.example(), email: "franz@dropbox.com", country: "US", locale: "en", referralLink: "https://db.tt/ZITNuhtI", space: Space.example(), team: Team.example(), isPaired: true)
    }
}
