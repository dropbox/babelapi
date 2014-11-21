import Foundation

enum Result<T> {
    case Success(T)
    case Failure
}

class Client {
    init() {
      // ...
    }

    // MARK: - Users

    /// Get information about a user's account.
    func getInfo(accountID: AccountID, completionHandler: (Result<BasicAccountInfo>) -> Void) {
        // ...
    }

    /// Get information about the authorized user's account.
    func getInfoMe(completionHandler: (Result<MeInfo>) -> Void) {
        // ...
    }
}
