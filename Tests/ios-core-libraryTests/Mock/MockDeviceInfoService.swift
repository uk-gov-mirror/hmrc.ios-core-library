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

import ios_core_library
import UIKit

open class MockDeviceInfoService: DeviceInfoService {

    public var returnScreenPixelWidth = 100
    public var returnScreenPixelHeight = 100
    public var returnScalingFactor = CGFloat(2)
    public var returnIPAddresses = ["ip 1", "ip 2"]

    public var returnAppInstallationId = "an installation id"
    public var returnAppVersion = "app-Version"
    public var returnOperatingSystem = "iOS-Version"
    public var returnDevice = "a-Device"

    public var screenPixelWidthCalled = false
    public var screenPixelHeightCalled = false
    public var scalingFactorCalled = false
    public var getIPAddressesCalled = false

    public var appInstallationIdCalled = false
    public var appVersionCalled = false
    public var operatingSystemCalled = false
    public var deviceCalled = false

    public init() {}

    public var appInstallationId: String {
        appInstallationIdCalled = true
        return returnAppInstallationId
    }

    public var appVersion: String {
        appVersionCalled = true
        return returnAppVersion
    }

    public var operatingSystem: String {
        operatingSystemCalled = true
        return returnOperatingSystem
    }

    public var device: String {
        deviceCalled = true
        return returnDevice
    }

    public var screenPixelWidth: Int {
        screenPixelWidthCalled = true
        return returnScreenPixelWidth
    }
    public var screenPixelHeight: Int {
        screenPixelHeightCalled = true
        return returnScreenPixelHeight
    }
    public var scalingFactor: CGFloat {
        scalingFactorCalled = true
        return returnScalingFactor
    }
    public func getIPAddresses() -> [String] {
        getIPAddressesCalled = true
        return returnIPAddresses
    }
}
