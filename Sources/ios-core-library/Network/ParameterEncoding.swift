//
//  Copyright 2019 HM Revenue & Customs
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public enum ParameterEncoding {
    public enum Errors: Error {
        case invalidURLError
    }
    case url
    case json

    func encode(_ request: URLRequest, parameters: [String: Any]) throws -> URLRequest {
        guard let url = request.url else {
            throw Errors.invalidURLError
        }
        switch self {
        case .url:
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let existingItems = components?.queryItems
            var queryItems = parameters.map { URLQueryItem(name: $0, value: "\($1)") }

            if let existingItems = existingItems {
                existingItems.forEach { queryItems.append($0) }
            }
            components?.queryItems = queryItems
            var mutableRequest = request
            mutableRequest.url = components?.url ?? url
            return mutableRequest
        case .json:
            let options = JSONSerialization.WritingOptions.prettyPrinted
            let json = try JSONSerialization.data(withJSONObject: parameters, options: options)
            var mutableRequest = request
            mutableRequest.httpBody = json
            return mutableRequest
        }
    }
}
