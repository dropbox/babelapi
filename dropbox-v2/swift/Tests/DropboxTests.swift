import UIKit
import XCTest
import Dropbox

class DropboxTests: XCTestCase {

    let accessToken = "2iie9gy0uB0AAAAAAAABs56wu6j6dSBOiIZ_aG3jVeTpEmDocz3eTpwkFWd2IPLC"

    var client: Dropbox.Client!
    
    override func setUp() {
        super.setUp()

        client = Dropbox.Client(accessToken: accessToken)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: -
    
    func testGetInfoMe() {
        let expectation = expectationWithDescription("getInfo")

        client.getInfoMe { (result) in
            expectation.fulfill()

            switch result {
            case .Success(let info):
                XCTAssertEqual(info.accountID, "dbid:AAApUbI47KUFkojkBTTEIdPftZSgOypGd6M")
                XCTAssertEqual(info.name.givenName, "Mattt")
                XCTAssertEqual(info.referralLink, "https://db.tt/0JcqM0yz")
            case .Failure:
                XCTFail()
            }
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
    }
}
