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

import UIKit
import DeviceKit

public protocol DeviceInfoService {
    var appInstallationId: String { get }
    var appVersion: String { get }
    var operatingSystem: String { get }
    var device: String { get }
    var screenPixelWidth: Int { get }
    var screenPixelHeight: Int { get }
    var scalingFactor: CGFloat { get }
    func getIPAddresses() -> [String]
}

extension MobileCore.Device.Info {
    public struct Service: DeviceInfoService {
        public let appVersion: String
        public let operatingSystem: String
        public let device: String

        public var screenPixelWidth: Int {
            return Int(UIScreen.main.currentMode?.size.width ?? 0)
        }
        public var screenPixelHeight: Int {
            return Int(UIScreen.main.currentMode?.size.height ?? 0)
        }
        public var scalingFactor: CGFloat {
            return UIScreen.main.scale
        }

        static func standard() -> Service {
            guard !MobileCore.config.uiTests.areRunning else {
                return Service(
                    appVersion: "UI_TEST_APP_VERSION",
                    operatingSystem: "UI_TEST_OS",
                    device: Device.current.description)
            }
            return Service(
                appVersion: UIApplication.versionBuild(),
                operatingSystem: UIDevice.current.systemVersion,
                device: Device.current.description)
        }

        public var appInstallationId: String {
            let appInstallationId = "appInstallationId"
            let keychain = MobileCore.config.appConfig.appKeychain
            guard let existingId = keychain.getString(appInstallationId) else {
                let newId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                keychain.putString(appInstallationId, value: newId)

                return newId
            }
            return existingId
        }

        public func getIPAddresses() -> [String] {
            var addresses: [String] = []
            var ifaddr: UnsafeMutablePointer<ifaddrs>?
            if getifaddrs(&ifaddr) == 0 {
                var ptr = ifaddr
                while ptr != nil {
                    defer { ptr = ptr?.pointee.ifa_next }

                    let interface = ptr?.pointee
                    let addrFamily = interface?.ifa_addr.pointee.sa_family
                    if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname,
                                    socklen_t(hostname.count),
                                    nil,
                                    socklen_t(0),
                                    NI_NUMERICHOST)
                        let ipAddress = String(cString: hostname)
                        if ipAddress.contains(".") {
                            addresses.append(ipAddress)
                        }
                    }
                }

                freeifaddrs(ifaddr)
            }

            return addresses
        }
    }
}
