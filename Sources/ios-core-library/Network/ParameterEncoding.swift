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
    case form

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
        case .form:
            var mutableRequest = request
            mutableRequest.httpBody = encodeParameters(parameters: parameters)
            return mutableRequest
        }
    }

    private func percentEscapeString(string: String) -> String {
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: "-._* ")

        return string
            .addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)!
            .replacingOccurrences(of: " ", with: "+")
    }

    private func encodeParameters(parameters: [String: Any]) -> Data? {
        let parameterArray = parameters.map { (key, value) -> String in
            "\(key)=\(percentEscapeString(string: value as? String ?? ""))"
        }

        return parameterArray.joined(separator: "&").data(using: .utf8)
    }
}
