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

class ExampleNetworkAuditDelegate: NetworkServiceAuditDelegate {
    func trackAuditEventIfRequired(request: URLRequest, data: Data, response: URLResponse) {
        print("TODO: Audit HTTP request: \n\(request)\nData: \(data)\nResponse: \(response)")
    }
}

class ExampleNetworkAnalyticsDelegate: NetworkServiceAnalyticsDelegate {
    func trackAnalyticEvent(eventCategory: String, eventAction: String, eventLabel: String?, eventValue: NSNumber?) {
        let eventLabel = eventLabel ?? "(NO Label)"
        var val = "(NO Value)"

        if let eventValue = eventValue {
            val = "\(eventValue)"
        }

        print(
            "TODO: Track HTTP request analytics Category: \n\(eventCategory)\nAction: \n\(eventAction)\nLabel: \(eventLabel)\nValue: \(val)\n\n"
        )
    }
}
