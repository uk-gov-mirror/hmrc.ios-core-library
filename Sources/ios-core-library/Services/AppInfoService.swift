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

public protocol AppInfoService {
    var apiToken: String { get }
    var apiUrl: String { get }
    var appName: String { get }
    var version: String { get }
    var build: String { get }
    var privacyVersion: Int { get }
}

extension MobileCore.AppInfo {
    open class Service: AppInfoService, InfoPListServiceInjected {
        struct Keys {
            static let apiToken = "API Token"
            static let apiUrl = "API URL"
            static let appName = "CFBundleDisplayName"
            static let appVersion = "CFBundleShortVersionString"
            static let appBuild = "CFBundleVersion"
            static let privacyVersion = "PrivacyVersion"
        }

        public let infoDictionary: [String: Any] = {
            guard let dict = Bundle.main.infoDictionary else {
                fatalError("Couldnt get app info plist from bundle")
            }
            return dict
        }()

        public subscript<T>(name: String) -> T {
            guard let value = infoDictionary[name] as? T else {
                fatalError("Missing \(name) in info.plist")
            }
            return value
        }

        public var apiToken: String {
            let token: String = self[Keys.apiToken]
            return token
        }

        public var apiUrl: String {
            let url: String = self[Keys.apiUrl]
            return url
        }

        public var appName: String {
            let appName: String = self[Keys.appName]
            return appName
        }

        public var version: String {
            let version: String = self[Keys.appVersion]
            return version
        }

        public var build: String {
            let build: String = self[Keys.appBuild]
            return build
        }

        public var privacyVersion: Int {
            let version: Int = self[Keys.privacyVersion]
            return version
        }
    }
}
