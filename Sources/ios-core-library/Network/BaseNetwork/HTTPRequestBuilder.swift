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
public typealias ModifyNetworkRequest = ((_ request: URLRequest) -> URLRequest)
extension MobileCore.HTTP {

    open class RequestBuilder: NSObject, FraudPreventionServiceInjected {
        public enum Errors: Error {
            case selfDeallocated
        }

        public private(set) var method: MobileCore.HTTP.Method = .get
        public private(set) var url: URL!
        public private(set) var data: [String: Any]?
        public private(set) var headers: [String: String]?
        ///Set to false to stop anti fraud headers being appended to request. Defaults to true
        public var includeAntiFraudHeaders = true
        ///A final chance to modify the request generated as result of call to build(_:)
        public var modifyRequest: ModifyNetworkRequest!

        public override init() {}

        public init(url: URL,
                    method: Method = .get,
                    data: [String: Any] = [:],
                    headers: [String: String] = [:]) {

            self.method = method
            self.url = url
            self.data = data
            self.headers = headers
            super.init()
        }

        public init(url: URL,
                    method: Method = .get,
                    data: Data?,
                    headers: [String: String] = [:]) {

            self.method = method
            self.url = url
            self.headers = headers
            super.init()
            self.setData(data)
        }

        @discardableResult public func setMethod(_ method: MobileCore.HTTP.Method) -> MobileCore.HTTP.RequestBuilder {
            self.method = method
            return self
        }

        @discardableResult public func setUrl(_ url: URL) -> MobileCore.HTTP.RequestBuilder {
            self.url = url
            return self
        }

        @discardableResult public func setData(_ data: [String: Any]) -> MobileCore.HTTP.RequestBuilder {
            self.data = data
            return self
        }

        @discardableResult public func setData(_ data: Data?) -> MobileCore.HTTP.RequestBuilder {
            guard
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let json = jsonData as? [String: Any]
            else {
                self.data = nil
                return self
            }
            self.data = json
            return self
        }

        @discardableResult public func setHeaders(_ headers: [String: String]) -> MobileCore.HTTP.RequestBuilder {
            self.headers = headers
            return self
        }

        open func modify(url: URL) -> URL {
            return url
        }

        // MARK: - Subclassing

        open func additionalHeaders(_ handler: @escaping (Result<[String: String], Error>) -> Void ) {
            handler(.success([:]))
        }

        open func customCachePolicy(_ handler: @escaping (URLRequest.CachePolicy) -> Void ) {
            handler(.useProtocolCachePolicy)
        }

        open func build(_ handler: @escaping (Result<URLRequest, Error>) -> Void ) {
            let url = modify(url: self.url)
            var request = URLRequest(url: url)

            request.httpMethod = method.rawValue
            let requestHeaders = request.allHTTPHeaderFields ?? [String: String]()
            let antiFraudHeaders = fraudPrevention.preventionHeaders

            var allHeaders = headers ?? [:]
            requestHeaders.forEach {allHeaders[$0] = $1 }

            if includeAntiFraudHeaders {
                antiFraudHeaders.forEach {allHeaders[$0] = $1 }
            }

            customCachePolicy { cachePolicy in
                request.cachePolicy = cachePolicy
            }
            //Generate additional headers
            self.additionalHeaders { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(headers):
                    headers.forEach { allHeaders[$0] = $1 }

                    request.allHTTPHeaderFields = allHeaders

                    do {
                        if let data = self.data {
                            switch self.method {
                            case .get:
                                request = try ParameterEncoding.url.encode(request, parameters: data)
                            case .post, .put:
                                switch request.value(forHTTPHeaderField: ContentType.key) {
                                case ContentType.formUrlEncoded:
                                    request = try ParameterEncoding.form.encode(request, parameters: data)
                                case ContentType.json:
                                    request = try ParameterEncoding.json.encode(request, parameters: data)
                                case nil:
                                    request.setValue(ContentType.json, forHTTPHeaderField: ContentType.key)
                                    request = try ParameterEncoding.json.encode(request, parameters: data)
                                default:
                                    request = try ParameterEncoding.url.encode(request, parameters: data)
                                }
                            case .delete:
                                break // No parameters for delete
                            }
                        }
                    } catch {
                        handler(.failure(error))
                        return
                    }
                    //let user code modify the request if they need
                    if let modifyHandler = self.modifyRequest {
                        request = modifyHandler(request)
                    }
                    handler(.success(request))
                case let .failure(error):
                    handler(.failure(error))
                }
            }
        }

        private struct ContentType {
            static let key = "Content-Type"
            static let json = "application/json"
            static let formUrlEncoded = "application/x-www-form-urlencoded"
        }
    }
}
