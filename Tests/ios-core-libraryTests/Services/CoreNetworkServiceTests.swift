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

@testable import MobileCore
import XCTest

class CoreNetworkServiceTests: CoreUnitTestCase {

    class NetworkAuditDelegate: NetworkServiceAuditDelegate {
        var lastRequest: URLRequest!
        var lastResponseBody: String!
        var lastResponseStatusCode: Int!
        var trackAuditEventCallCount = 0

        func trackAuditEventIfRequired(request: URLRequest, data: Data, response: URLResponse) {
            trackAuditEventCallCount += 1
            guard let httpResponse = response as? HTTPURLResponse else { return }
            let statusCode = httpResponse.statusCode
            if statusCode >= 400 && statusCode != 429 {
                lastRequest = request
                lastResponseStatusCode = statusCode
                lastResponseBody = String(data: data, encoding: String.Encoding.utf8) ?? ""
            }
        }
    }

    class NetworkAnalyticsDelegate: NetworkServiceAnalyticsDelegate {
        var lastEventCategory: String!
        var lastEventAction: String!
        var lastEventLabel: String?
        var lastEventValue: NSNumber?

        func trackAnalyticEvent(eventCategory: String, eventAction: String, eventLabel: String?, eventValue: NSNumber?) {
            lastEventCategory = eventCategory
            lastEventAction = eventAction
            lastEventLabel = eventLabel
            lastEventValue = eventValue
        }
    }

    // MARK: - SUT override

    override func createMockCoreNetworkService() -> MockCoreNetworkService? {
        return nil
    }

    // MARK: -

    var sut: CoreNetworkService!
    static let urlThatDoesntMatter = URL(string: "https://www.doesntMatter.com/NetworkServiceTests")!
    var defaultData: Data!

    var requestBuilder: MobileCore.HTTP.RequestBuilder!
    // swiftlint:disable:next weak_delegate
    var analyticsDelegate: NetworkAnalyticsDelegate!
    // swiftlint:disable:next weak_delegate
    var auditDelegate: NetworkAuditDelegate!

    var url: URL {
        return self.requestBuilder.url
    }

    override func setUp() {
        super.setUp()
        sut = MobileCore.Injection.Service.network.injectedObject()
        analyticsDelegate = NetworkAnalyticsDelegate()
        auditDelegate = NetworkAuditDelegate()
        MobileCore.Network.configure(analyticsDelegate: analyticsDelegate, auditDelegate: auditDelegate)

        // swiftlint:disable:next force_try
        defaultData = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: .prettyPrinted)
        requestBuilder = MobileCore.HTTP.RequestBuilder(
            url: CoreNetworkServiceTests.urlThatDoesntMatter,
            method: .get,
            data: [:],
            headers: [:])
    }

    func test_makingASuccessfulNetworkCall_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 400)
    }

    func test_makingASuccessfulNetworkCall_whenPolicySuppressesSpinner_shouldNotDisplayTheSpinner() {
        assertWhenPolicySuppressesSpinnerItIsNotDisplayedAndDismissedFor(status: 200)
    }

    func test_makingAFailedNetworkCallWhichReturns400_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 400)
    }

    func test_makingAFailedNetworkCallWhichReturns401_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 401)
    }

    func test_makingAFailedNetworkCallWhichReturns403_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 403)
    }

    func test_makingAFailedNetworkCallWhichReturns404_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 404)
    }

    func test_makingAFailedNetworkCallWhichReturns410_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 410)
    }

    func test_makingAFailedNetworkCallWhichReturns423_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 423)
    }

    func test_makingAFailedNetworkCallWhichReturns500_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: 500)
    }

    func test_makingNetworkCallWhichErrors_whenPolicyAllowsSpinner_shouldDisplayAndDismissTheSpinner() {
        allowSpinner()

        assertWhenRequestMade(result: 500, result: nil, shouldReturnError: true,
                              description: "Await spinner") { _, _, file, line  in

            XCTAssertEqual(self.mockSpinner.showCount, 1, file: file, line: line)
            XCTAssertEqual(self.mockSpinner.popActivityCount, 1, file: file, line: line)
        }
    }

    func test_trackAuditEventIfRequired_sendsAuditEvent() {
        assertWhenRequestMade(result: 400, result: nil, description: "Track Audit Event") { _, _, _, _  in

            XCTAssertEqual(self.auditDelegate.trackAuditEventCallCount, 1)

            guard let requestUrl = self.auditDelegate.lastRequest?.url?.absoluteString else {
                XCTFail("Request url not logged")
                return
            }
            XCTAssertTrue(requestUrl.contains(self.url.absoluteString))
            XCTAssertEqual(self.auditDelegate.lastResponseStatusCode, 400)

            XCTAssertEqual(self.auditDelegate.lastResponseBody, String(data: self.defaultData, encoding: .utf8))
        }
    }

    func test_401FromServiceIsTreatedAs403_andCausesLogoutErrorToBeGenerated() {
        assertWhenRequestMade(
        result: 401,
        result: nil,
        description: "401 should be treated as 403"
        ) { error, response, _, _  in
            guard response == nil else {
                XCTFail("Shouldnt be a response")
                return
            }

            guard let error = error else {
                XCTFail("No error returned")
                return
            }
            guard let serviceError = error as? MobileCore.Network.ServiceError else {
                XCTFail("Returned an unexpected type of error")
                return
            }
            switch serviceError {
            case .logout:
                _ = 0
            default:
                XCTFail("Returned an unexpected type of error")
            }

        }
    }

    func test_403FromService_correctAnalyticsEventIsLogged() {
        assertWhenRequestMade(
            result: 403,
            result: nil,
            description: "403 should be logged by analytics"
        ) { error, response, _, _  in
            guard response == nil else {
                XCTFail("Shouldnt be a response")
                return
            }

            guard error != nil else {
                XCTFail("No error returned")
                return
            }

            XCTAssertEqual(self.analyticsDelegate.lastEventCategory, "errors")
            XCTAssertEqual(self.analyticsDelegate.lastEventLabel, "403 forbidden")
            XCTAssertEqual(self.analyticsDelegate.lastEventAction, "forbidden")
        }
    }

    func test_403FromService_correctSplunkEventIsLogged() {
        assertWhenRequestMade(
            result: 403,
            result: nil,
            description: "403 should be logged by splunk"
        ) { error, response, _, _  in
            guard response == nil else {
                XCTFail("Shouldnt be a response")
                return
            }

            guard error != nil else {
                XCTFail("No error returned")
                return
            }
            self.waitUntilOrAssert("Audit event is captured", { () -> String? in
                guard let code = self.auditDelegate.lastResponseStatusCode else {
                    return "No status code returned"
                }
                guard let url = self.auditDelegate.lastRequest?.url?.absoluteString else {
                    return "No URL captured"
                }
                guard code == 403 else {
                    return "Status code is incorrect"
                }
                guard url.contains(find: CoreNetworkServiceTests.urlThatDoesntMatter.absoluteString) else {
                    return "URL is wrong"
                }
                return nil
            })
        }
    }

    func mockResponse(code: Int, data: Data?=nil, shouldReturnError: Bool=false) {
        mockHTTPResponse(code, requestUrlMustContainString: url.absoluteString, data: data, shouldReturnError: shouldReturnError)
    }

    func mockHTTPResponse(_ code: Int,
                          requestUrlMustContainString: String?=nil,
                          data: Data?=nil,
                          shouldReturnError: Bool = false) {
        var response: Mock.Core.HTTP.Response!
        var data = data

        if data == nil {
            data = defaultData
        }
        if let searchText = requestUrlMustContainString {
            response = Mock.Core.HTTP.Response(code: code, data: data, requestUrlMustContainString: searchText)
        } else {
            response = Mock.Core.HTTP.Response(code: code, data: data)
        }
        if shouldReturnError {
            response = response.setError()
        }
        mockCoreHTTPService.queuedResponses = [ response ]
    }

    func allowSpinner() {
        let policy = MobileCore.Network.Spinner.Policy(suppressedEndpointPaths: [], extendDelayEndpointPaths: [])
        MobileCore.Injection.Service.networkSpinnerPolicy.inject(policy)
    }

    func suppressSpinner() {
        let policy = MobileCore.Network.Spinner.Policy(suppressedEndpointPaths: [url.absoluteString], extendDelayEndpointPaths: [])
        MobileCore.Injection.Service.networkSpinnerPolicy.inject(policy)
    }

    func assertWhenRequestMade(
        result code: Int,
        result data: Data?=nil,
        shouldReturnError: Bool=false,
        description: String,
        file: StaticString = #file,
        line: UInt = #line,
        _ assertions: @escaping ((Error?, MobileCore.HTTP.Response?, StaticString, UInt) -> Void)) {

        mockResponse(code: code, data: data, shouldReturnError: shouldReturnError)

        let thisExpectation = expectation(description: description)
        var response: MobileCore.HTTP.Response!
        var responseError: Error?

        sut.data(request: requestBuilder) { (result) in
            switch result {
            case .success(let resp):
                response = resp
                if code > 399 {
                    XCTFail("Should not call success block", file: file, line: line)
                }
                CoreTestHelpers.delay {
                    thisExpectation.fulfill()
                }
            case .failure(let error):
                responseError = error
                if code < 400 {
                    XCTFail("Should not call failure block \(error)", file: file, line: line)
                }
                CoreTestHelpers.delay {
                    thisExpectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: Test.Timeout) { (error) in
            if let error = responseError {
                assertions(error, response, file, line)
            } else if let error = error {
                assertions(error, response, file, line)
            } else {
                assertions(nil, response, file, line)
            }
        }
        mockCoreHTTPService.waitForRequestQueueToComplete()
    }

    // MARK: - Helpers

    private func assertWhenPolicyAllowsSpinnerItIsDisplayedAndDismissedFor(status: Int, file: StaticString = #file, line: UInt = #line) {
        allowSpinner()
        assertWhenRequestMade(result: status, result: nil, description: "Await spinner", file: file, line: line) { _, _, file, line  in
            XCTAssertEqual(self.mockSpinner.showCount, 1, file: file, line: line)
            XCTAssertEqual(self.mockSpinner.popActivityCount, 1, file: file, line: line)
        }
    }

    private func assertWhenPolicySuppressesSpinnerItIsNotDisplayedAndDismissedFor(status: Int, file: StaticString = #file, line: UInt = #line) {
        suppressSpinner()
        assertWhenRequestMade(result: status, result: nil, description: "Await spinner") { _, _, file, line  in
            XCTAssertEqual(self.mockSpinner.showCount, 0, file: file, line: line)
            XCTAssertEqual(self.mockSpinner.popActivityCount, 0, file: file, line: line)
        }
    }
}
