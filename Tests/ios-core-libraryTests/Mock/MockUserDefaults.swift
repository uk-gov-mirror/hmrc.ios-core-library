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
import ios_core_library

public class MockUserDefaults: UserDefaultsProtocol {

    public var lastSetKey = ""
    public var lastSetString: String?
    public var lastSetInt: Int?

    public var lastRemovedKey = ""

    public var lastRetrievedKey: String?

    public var valuesToReturn = [String: Any?]()

    public init() {}

    public func removeObject(forKey defaultName: String) {
        lastRemovedKey = defaultName
        valuesToReturn.removeValue(forKey: defaultName)
    }

    public func object(forKey defaultName: String) -> Any? {
        lastRetrievedKey = defaultName
        return valuesToReturn[defaultName] as Any?
    }

    public func set(_ value: Any?, forKey defaultName: String) {
        lastSetKey = defaultName
        if let value = value as? String {
            lastSetString = value
        }
        if let value = value as? Int {
            lastSetInt = value
        }

        valuesToReturn[defaultName] = value
    }

    public func string(forKey defaultName: String) -> String? {
        lastRetrievedKey = defaultName
        return valuesToReturn[defaultName] as? String ?? nil
    }

    public func bool(forKey defaultName: String) -> Bool {
        lastRetrievedKey = defaultName
        return valuesToReturn[defaultName] as? Bool ?? false
    }

    public func integer(forKey defaultName: String) -> Int {
        lastRetrievedKey = defaultName
        return valuesToReturn[defaultName] as? Int ?? 0
    }
}
