/*
 * Copyright 2019 HM Revenue & Customs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@testable import ios_core_library
import Foundation
import XCTest
import ios_test_helpers

class RequestBuilderTests: CoreUnitTestCase {
    var sut: MobileCore.HTTP.RequestBuilder!
    let testJourneyId = "RequestBuilderTestsJourneyID"
    static let unimportantURLString = "http://RequestBuilderTests.com/doesntMatter"

    var unimportantURL: URL {
        return URL(string: RequestBuilderTests.unimportantURLString)!
    }

    override func setUp() {
        super.setUp()

        sut = MobileCore.HTTP.RequestBuilder(
            url: unimportantURL,
            method: .get,
            data: [:],
            headers: [:])

        mockJourneyService.journeyId = testJourneyId
    }

    func assertFraudHeaders(in headers: [String: String], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(headers["Gov-Client-Screens"], "width=ScreenWidth&height=ScreenHeight&scaling-factor=2", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-Device-ID"], "AppInstallId", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-Timezone"], "TimeZone", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-Window-Size"], "width=ScreenWidth&height=ScreenHeight", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-Connection-Method"], "MOBILE_APP_DIRECT", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-User-Agent"], "iOS/12.0 (iPhoneX)", file: file, line: line)
        XCTAssertEqual(headers["Gov-Client-Local-IPs"], "111.111.111.111,222.222.222.222", file: file, line: line)
        XCTAssertEqual(headers["Gov-Vendor-Version"], "appName=version.buildbuild", file: file, line: line)
    }

    func test_fraudPreventionHeadersAreAdded() {
        let initialURL = URL(string: "\(RequestBuilderTests.unimportantURLString)")!
        sut = MobileCore.HTTP.RequestBuilder(
            url: initialURL,
            method: .get,
            data: [:],
            headers: [:])

        let expect = expectation(description: "Fraud prevention headers are added")
        var headers = [String: String]()

        sut.fraudPrevention.set(fraudPreventionHeaders: [
            "Gov-Client-Screens": "width=ScreenWidth&height=ScreenHeight&scaling-factor=2",
            "Gov-Client-Timezone": "TimeZone",
            "Gov-Vendor-Version": "appName=version.buildbuild",
            "Gov-Client-Device-ID": "AppInstallId",
            "Gov-Client-Window-Size": "width=ScreenWidth&height=ScreenHeight",
            "Gov-Client-Connection-Method": "MOBILE_APP_DIRECT",
            "Gov-Client-User-Agent": "iOS/12.0 (iPhoneX)",
            "Gov-Client-Local-IPs": "111.111.111.111,222.222.222.222"
        ])
        sut.build { (result) in
            switch result {
            case .success(let urlRequest):
                headers = urlRequest.allHTTPHeaderFields ?? [:]
                expect.fulfill()
            case .failure:
                XCTFail("Error building request")
            }
        }

        waitForExpectations(timeout: Test.Timeout) { error in
            if let error = error {
                print("Build request timed out: \(String(describing: error))")
            }
        }

        assertFraudHeaders(in: headers)
    }

    func test_urlWithExistingQueryString_stillContainsExistingQueryComponents_afterComponentAppendedToQueryString() {
        let expectedKey = "QueryKey"
        let expectedVal = "QueryVal"

        let appendedKey = "AppendedQueryKey"
        let appendedVal = "AppendedQueryVal"

        let initialURL = URL(string: "\(RequestBuilderTests.unimportantURLString)?\(expectedKey)=\(expectedVal)")!
        sut = MobileCore.HTTP.RequestBuilder(
            url: initialURL,
            method: .get,
            data: [appendedKey: appendedVal as NSString],
            headers: [:])

        let expect = expectation(description: "Components are not lost")
        var builtURL: URL!

        sut.build { (result) in
            switch result {
            case .success(let urlRequest):
                builtURL = urlRequest.url
                expect.fulfill()
            case .failure:
                XCTFail("Error building request")
            }
        }

        waitForExpectations(timeout: Test.Timeout) { error in
            if let error = error {
                print("Build request timed out: \(String(describing: error))")
            }
        }

        let components = builtURL.queryStringComponents

        guard let existing = (components.filter {$0.name == expectedKey}).first else {
            XCTFail("Existing key was lost")
            return
        }

        XCTAssertEqual(existing.value, expectedVal)
        guard let appended = (components.filter {$0.name == appendedKey}).first else {
            XCTFail("Appended key was not added")
            return
        }
        XCTAssertEqual(appended.value, appendedVal)
    }

    func test_builderSucceeds_whenMethodIsPut() {
        sut = MobileCore.HTTP.RequestBuilder(
            url: URL(string: "\(RequestBuilderTests.unimportantURLString)")!,
            method: .put,
            data: [:],
            headers: [:])

        let expect = expectation(description: "Expect build to succeed")

        sut.build { (result) in
            switch result {
            case .success:
                expect.fulfill()
            case .failure:
                XCTFail("Error building request")
            }
        }

        waitForExpectations(timeout: Test.Timeout) { error in
            if let error = error {
                print("Build request timed out: \(String(describing: error))")
            }
        }
    }

    func test_builderSucceeds_whenMethodIsPost() {
        sut = MobileCore.HTTP.RequestBuilder(
            url: URL(string: "\(RequestBuilderTests.unimportantURLString)")!,
            method: .post,
            data: [:],
            headers: [:])

        let expect = expectation(description: "Expect build to succeed")

        sut.build { (result) in
            switch result {
            case .success:
                expect.fulfill()
            case .failure:
                XCTFail("Error building request")
            }
        }

        waitForExpectations(timeout: Test.Timeout) { error in
            if let error = error {
                print("Build request timed out: \(String(describing: error))")
            }
        }
    }

    func test_builderSucceeds_whenMethodIsDelete() {
        sut = MobileCore.HTTP.RequestBuilder(
            url: URL(string: "\(RequestBuilderTests.unimportantURLString)")!,
            method: .delete,
            data: [:],
            headers: [:])

        let expect = expectation(description: "Expect build to succeed")

        sut.build { (result) in
            switch result {
            case .success(let request):
                XCTAssertNil(request.httpBody)
                expect.fulfill()
            case .failure:
                XCTFail("Error building request")
            }
        }

        waitForExpectations(timeout: Test.Timeout) { error in
            if let error = error {
                print("Build request timed out: \(String(describing: error))")
            }
        }
    }
}
