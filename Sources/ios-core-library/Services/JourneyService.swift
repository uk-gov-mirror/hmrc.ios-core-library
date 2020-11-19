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

///Responsible for keeping track of various session related things
public protocol JourneyService {
    var journeyId: String {get set}
    func resetJourneyId()

    func set(id: String)
    ///Returns the journey associated with the specified named event and description
    ///or nil if no journey id has been saved for this event.
    ///@param name anything you want as long as name + description == unique key
    ///@param description optional. anything you want as long as name + description == unique key
    func journeyId(forEvent name: String, description: String?) -> String?

    ///Associates the specified journey id with the supplied named event and description
    ///@param name anything you want as long as name + description == unique key
    ///@param description optional. anything you want as long as name + description == unique key
    func storeJourneyId(forEvent name: String, description: String?)

    ///Checks to see if the current journeyId matches the last stored journeyId
    ///for the supplied named event and description. Returns true if the journey id has changed
    ///or was never stored. False if journey id remains the same.
    ///@param name anything you want as long as name + description == unique key
    ///@param description optional. anything you want as long as name + description == unique key
    func hasStartedNewJourney(forEvent name: String, description: String?) -> Bool

}

extension MobileCore.Journey {

    public class Service: JourneyService, UserDefaultsInjected {

        private var _journeyId: String?

        public func set(id: String) {
            journeyId = id
        }

        public var journeyId: String {
            get {
                Log.info(message: "Get journeyId")
                if UITests.areRunning { return "UI_Test_Journey_ID" }

                if let id = _journeyId {
                    Log.info(message: "Use existing journeyId: '\(id)'")
                    return id
                } else {
                    let guid = NSUUID().uuidString
                    _journeyId = guid
                    Log.info(message: "Generated new journeyId: '\(guid)'")
                    return guid
                }
            }
            set {
                Log.info(message: "Set journeyId: '\(newValue)'")
                _journeyId = newValue
            }
        }

        public func resetJourneyId() {
            _journeyId = nil
        }

        // MARK: - Storage and retrieval

        public func storeJourneyId(forEvent name: String, description: String?) {
            let journeyId = self.journeyId
            let key = storageKey(eventName: name, description: description)
            userDefaults.set(journeyId, forKey: key)
        }

        public func journeyId(forEvent name: String, description: String?=nil) -> String? {
            let key = self.storageKey(eventName: name, description: description)
            return userDefaults.string(forKey: key)
        }

        // MARK: - Logic

        public func hasStartedNewJourney(forEvent name: String, description: String?=nil) -> Bool {
            if UITests.areRunning { return true }
            let currentJourneyId = self.journeyId

            if let lastJourneyId = journeyId(forEvent: name, description: description) {
                return currentJourneyId != lastJourneyId
            } else {
                return true
            }
        }
    }
}

extension JourneyService {
    // MARK: - Helpers

    public func storageKey(eventName: String, description: String?=nil) -> String {
        if let description = description {
            return "\(eventName)_\(description)"
        } else {
            return "\(eventName)"
        }
    }
}
