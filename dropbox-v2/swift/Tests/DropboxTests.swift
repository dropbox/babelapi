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

    func testGetInfo() {
        let expectation = expectationWithDescription("getInfo")

        let accountId = "dbid:AAApUbI47KUFkojkBTTEIdPftZSgOypGd6M"

        client.getInfo(accountId) { (result) in
            expectation.fulfill()

            switch result {
            case .Success(let .Me(info)):
                XCTAssertEqual(info.accountID, "dbid:AAApUbI47KUFkojkBTTEIdPftZSgOypGd6M")
                XCTAssertEqual(info.name.givenName, "Mattt")
            default:
                XCTFail()
            }
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testGetInfoMe() {
        let expectation = expectationWithDescription("getInfoMe")

        client.getInfoMe { (result) in
            expectation.fulfill()

            switch result {
            case .Success(let .Me(info)):
                XCTAssertEqual(info.accountID, "dbid:AAApUbI47KUFkojkBTTEIdPftZSgOypGd6M")
                XCTAssertEqual(info.name.givenName, "Mattt")
                XCTAssertEqual(info.referralLink, "https://db.tt/0JcqM0yz")
            default:
                XCTFail()
            }
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
    }
}
