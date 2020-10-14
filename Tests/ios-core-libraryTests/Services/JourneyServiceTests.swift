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

import XCTest
import ios_core_library
import ios_test_helpers

class JourneyServiceTests: CoreUnitTestCase {

    var service: JourneyService!

    let initialJourneyId = "Journey123"
    let eventName = "AnEvent"
    let eventDescription = "SomeDescriptionOrParameterOfEvent"
    var userDefaultsKey = ""

    override func createMockJourneyService() -> MockJourneyService? {
        //we dont want to mock the journey service as its the SUT
        return nil
    }

    override func setUp() {
        super.setUp()
        service = MobileCore.Injection.Service.journey.injectedObject() as JourneyService
        service.set(id: initialJourneyId)
        userDefaultsKey = service.storageKey(eventName: eventName, description: description)
    }

    func testResetJourneyId_thenJourneyIdIsRegenerated() {
        XCTAssertEqual(service.journeyId, initialJourneyId)
        service.resetJourneyId()
        XCTAssertNotEqual(service.journeyId, initialJourneyId)
    }

    func testStoreAndRetrieveJourneyIdForEvent_whenEventNameAndDescriptionAreSupplied_thenJourneyIdIsStored() {
        service.storeJourneyId(forEvent: eventName, description: eventDescription)

        let storedJourneyId = service.journeyId(forEvent: eventName, description: eventDescription)
        XCTAssertEqual(storedJourneyId, initialJourneyId)
    }

    func testHasStartedNewJourneyCalled_whenJourneyIdHasChanged_thenTrueIsReturned() {
        service.storeJourneyId(forEvent: eventName, description: eventDescription)
        service.set(id: "AnotherJourneyId")
        mockUserDefaults!.valuesToReturn = [userDefaultsKey: "SomeDifferentJourneyId"]
        let newJourneyStarted = service.hasStartedNewJourney(forEvent: eventName, description: eventDescription)
        XCTAssertTrue(newJourneyStarted)
    }

    func testHasStartedNewJourneyCalled_whenJourneyIdHasNotYetBeenStored_thenTrueIsReturned() {
        let newJourneyStarted = service.hasStartedNewJourney(forEvent: eventName, description: eventDescription)
        XCTAssertTrue(newJourneyStarted)
    }

    func testHasStartedNewJourneyCalled_whenJourneyIdHasNotChanged_thenFalseIsReturned() {
        service.storeJourneyId(forEvent: eventName, description: eventDescription)

        let newJourneyStarted = service.hasStartedNewJourney(forEvent: eventName, description: eventDescription)
        XCTAssertFalse(newJourneyStarted)
    }
}
