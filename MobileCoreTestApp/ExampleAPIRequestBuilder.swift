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
import MobileCore

class ExampleApiRequestBuilder: MobileCore.HTTP.RequestBuilder {

    override func additionalHeaders(_ handler: @escaping (Result<[String: String], Error>) -> Void) {
        //i.e fake network auth call
        delayedCall {
            let authHeaders = ["FakeAuthHeader": "Fake Auth Value"]
            handler(.success(authHeaders))
        }
    }

    init(path: String,
         method: MobileCore.HTTP.Method = .get,
         data: [String: Any] = [:],
         headers: [String: String] = [:]) {
        let baseAPIURL = URL(string: "https://www.tax.service.gov.uk")
        let url = URL(string: path, relativeTo: baseAPIURL)!
        super.init(url: url, method: method, data: data, headers: headers)
    }

    override func modify(url: URL) -> URL {
        var url = url
        let someQueryKey = "queryKeyToAppend"
        if !url.absoluteString.contains(someQueryKey) {
            url.addQueryString(params: [URLQueryItem(name: someQueryKey, value: "AQueryValue")])
            return url
        } else {
            return url
        }
    }
}
