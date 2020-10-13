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

open class MockJourneyService: JourneyService {

    public var resetJourneyIdCount = 0
    public var journeyIdForEventDescriptionCount = 0
    public var storeJourneyIdForEventDescriptionCount = 0
    public var hasJourneyIdForEventDescriptionCount = 0

    public init() {}

    public var returnValueFromHasStartedNewJourney = false
    public var storedEvents = [String: String]()
    private var _journeyId: String?
    public var journeyId: String {
        get {
            return _journeyId ?? ""
        }
        set {
            _journeyId = newValue
        }
    }

    public func set(id: String) {
        _journeyId = id
    }

    public func resetJourneyId() {
        _journeyId = nil
        resetJourneyIdCount += 1
    }

    public func journeyId(forEvent name: String, description: String?) -> String? {
        journeyIdForEventDescriptionCount += 1
        let key = self.storageKey(eventName: name, description: description)
        return storedEvents[key]
    }

    public func storeJourneyId(forEvent name: String, description: String?) {
        storeJourneyIdForEventDescriptionCount += 1
        let key = self.storageKey(eventName: name, description: description)
        storedEvents[key] = journeyId
    }

    public func hasStartedNewJourney(forEvent name: String, description: String?) -> Bool {
        hasJourneyIdForEventDescriptionCount += 1
        return returnValueFromHasStartedNewJourney
    }

}
