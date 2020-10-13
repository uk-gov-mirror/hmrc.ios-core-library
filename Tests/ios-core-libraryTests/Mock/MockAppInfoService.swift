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
import XCTest

open class MockAppInfoService: CoreMockBase, AppInfoService {
    var returnApiToken = "A Token"
    var returnApiUrl = "A URL"
    var returnAppName = "An app Name"
    var returnVersion = "A version"
    var returnBuild = "A Build"
    var returnPrivacyVersion = 1

    var apiTokenCallCount: Int = 0
    var apiUrlCallCount: Int = 0
    var appNameCallCount: Int = 0
    var versionCallCount: Int = 0
    var buildCallCount: Int = 0
    var privacyVersionCount: Int = 0

    public var apiToken: String {
        apiTokenCallCount += 1
        return returnApiToken
    }
    public var apiUrl: String {
        apiUrlCallCount += 1
        return returnApiUrl
    }
    public var appName: String {
        appNameCallCount += 1
        return returnAppName
    }
    public var version: String {
        versionCallCount += 1
        return returnVersion
    }
    public var build: String {
        buildCallCount += 1
        return returnBuild
    }
    public var privacyVersion: Int {
        privacyVersionCount += 1
        return returnPrivacyVersion
    }
}
