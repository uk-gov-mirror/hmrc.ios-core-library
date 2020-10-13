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

import Foundation
import XCTest
import ios_test_helpers
@testable import ios_core_library

open class CoreUnitTestCase: CoreTestCase {
    public var policy: NetworkSpinnerPolicy!
    public var mockCoreHTTPService: Mock.Core.HTTP.Service!
    public var mockCoreNetworkService: MockCoreNetworkService!
    public var mockSpinner: MockSpinner!
    public var mockJourneyService: MockJourneyService!
    public var mockDeviceInfoService: MockDeviceInfoService!
    public var mockUserDefaults: MockUserDefaults!
    public var mockInfoPListService: MockInfoPListService!
    public var mockAppInfoService: MockAppInfoService!
    public var mockDateService: MockDateService!

    override open func setUp() {
        super.setUp()
        MobileCore.config = MobileCore.Configuration(
            appConfig: MobileCore.Configuration.AppConfig(appKeychainID: "AppIDAccountKey")
        )
        MobileCore.config.unitTests = MobileCore.Configuration.UnitTests(areRunning: true)

        setupMocks()
    }

    override open func tearDown() {
        MobileCore.Injection.reset()
        super.tearDown()
    }

    // swiftlint:disable:next cyclomatic_complexity
    open func setupMocks() {
        if let mock = createMockCoreHTTPService() {
            mockCoreHTTPService = mock
            MobileCore.Injection.Service.http.inject(mock)
        }

        if let mock = createMockSpinner() {
            mockSpinner = mock
            MobileCore.Injection.Service.networkSpinner.inject(mock)
        }

        if let mock = createMockCoreNetworkService() {
            mockCoreNetworkService = mock
            MobileCore.Injection.Service.network.inject(mock)
        }

        if let policy = createSpinnerPolicy() {
            self.policy = policy
            MobileCore.Injection.Service.networkSpinnerPolicy.inject(policy)
        }

        if let mock = createMockJourneyService() {
            mockJourneyService = mock
            MobileCore.Injection.Service.journey.inject(mock)
        }

        if let mock = createMockDeviceInfoService() {
            mockDeviceInfoService = mock
            MobileCore.Injection.Service.deviceInfo.inject(mock)
        }

        if let mock = createMockUserDefaults() {
            mockUserDefaults = mock
            MobileCore.Injection.Service.userDefaults.inject(mock)
        }

        if let mock = createMockInfoPListService() {
            mockInfoPListService = mock
            MobileCore.Injection.Service.infoPlist.inject(mock)
        }

        if let mock = createMockAppInfoService() {
            mockAppInfoService = mock
            MobileCore.Injection.Service.appInfo.inject(mock)
        }

        if let mock = createMockDateService() {
            mockDateService = mock
            MobileCore.Injection.Service.date.inject(mock)
        }
    }

    open func createMockCoreHTTPService() -> Mock.Core.HTTP.Service? {
        return Mock.Core.HTTP.Service(testCase: self)
    }

    open func createMockSpinner() -> MockSpinner? {
        return MockSpinner()
    }

    open func createMockCoreNetworkService() -> MockCoreNetworkService? {
        return MockCoreNetworkService()
    }

    open func createSpinnerPolicy() -> NetworkSpinnerPolicy? {
        return MobileCore.Network.Spinner.Policy(dismissDelay: 0, extendDelay: 0)
    }

    open func createMockJourneyService() -> MockJourneyService? {
        return MockJourneyService()
    }

    open func createMockDeviceInfoService() -> MockDeviceInfoService? {
        return MockDeviceInfoService()
    }

    open func createMockUserDefaults() -> MockUserDefaults? {
        return MockUserDefaults()
    }

    open func createMockInfoPListService() -> MockInfoPListService? {
        return MockInfoPListService(coreTestCase: self)
    }

    open func createMockAppInfoService() -> MockAppInfoService? {
        return MockAppInfoService(coreTestCase: self)
    }

    open func createMockDateService() -> MockDateService? {
        return MockDateService(coreTestCase: self)
    }

    public func assertDescendantLabel(of view: UIView,
                                      matches text: String,
                                      partialMatch: Bool=false,
                                      in file: String = #file,
                                      at line: Int = #line) {

        let found = view.descendantLabelWith(text: text, allowPartialMatch: partialMatch) != nil
        let comparisonType = partialMatch ? "containing" : "matching"
        assertTrue(found, in: file, at: line) { "Failed to find decendant label \(comparisonType) text: '\(text)'" }
    }
}
