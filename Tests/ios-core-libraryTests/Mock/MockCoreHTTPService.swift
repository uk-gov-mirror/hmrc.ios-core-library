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

extension Mock.Core.HTTP {
    public class Response: CustomStringConvertible {
        let code: Int
        let data: Data
        let headers: [String: String]
        private(set) var error: Error?

        ///A string representing a URL or part of a URL.
        ///If partial, must uniquely identify a particular resource
        let requestUrlMustContainString: String?

        ///Stores the request that caused this reponse
        var request: URLRequest?

        public init(code: Int, data: Data?=nil, headers: [String: String] = [:]) {
            requestUrlMustContainString = nil
            self.code = code
            self.data = data ?? Data()
            self.headers = headers
            self.error = nil
        }

        public init(code: Int, data: Data?=nil, requestUrlMustContainString: String) {
            self.requestUrlMustContainString = requestUrlMustContainString
            self.code = code
            self.data = data ?? Data()
            self.headers = [:]
            self.error = nil
        }

        public init(code: Int, error: Error, headers: [String: String] = [:]) {
            requestUrlMustContainString = nil
            self.code = code
            self.data = Data()
            self.headers = headers
            self.error = error
        }

        ///Generates the reponse that is passed back to the code that made the request
        var urlResponse: MobileCore.HTTP.Response {
            guard let request = request else { fatalError("Invalid configuration. no request set!") }

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: self.code,
                httpVersion: nil,
                headerFields: self.headers
                )!
            return MobileCore.HTTP.Response(value: data, response: response)
        }

        func setError() -> Self {
            self.error = NSError(domain: "MockHTTPService", code: code, userInfo: nil)
            return self
        }

        public var description: String {
            var arr = ["Code \(code)"]
            if let request = request {
                arr.append("In response to: \(request)")
            }

            if let requestUrlMustContainString = requestUrlMustContainString {
                arr.append("URL Must contain: \(requestUrlMustContainString)")
            }

            let combined = arr.joined(separator: ", ")

            return "MockResponse [\(combined)]"
        }
    }

    enum Standard {
        case auth(success: Bool)

        var response: Response {
            switch self {
            case .auth(let success):
                let authURL = "http://api.doesntmatter.com/auth"
                if success {
                    let data = "{\"access_token\":\"token\",\"refresh_token\":\"refresh\",\"expires_in\":13800}".data(using: .utf8)!
                    return Response(code: 200, data: data, requestUrlMustContainString: authURL)
                } else {
                    return Response(code: 401, data: nil, requestUrlMustContainString: authURL)
                }
            }
        }
    }

    public class Service: CoreHTTPService, CustomStringConvertible {

        typealias GenerateResponse = ((_ request: URLRequest) -> Response?)
        let shouldLog = true
        public var queuedResponses = [Response]()

        ///Provide closure to this for full control over responses
        var generateResponse: GenerateResponse!

        public let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        ///stores responses together with the request that generated them
        private(set) var generatedResponses = [Response]()

        var lastResponse: Response? {
            return generatedResponses.last
        }

        let testCase: CoreUnitTestCase

        public init(testCase: CoreUnitTestCase) {
            self.testCase = testCase
            generateResponse = {(request) in
                guard let response = self.queuedResponses.first else {
                    return nil
                }
                self.queuedResponses.removeFirst()
                response.request = request
                return response
            }
        }

        public func waitForRequestQueueToComplete(in file: String = #file, at line: Int = #line) {
            testCase.waitUntilOrAssert("all requests in queue have been issued", in: file, at: line) {
                if self.queuedResponses.isEmpty {
                    return nil
                } else {
                    if shouldLog {
                        Log.debug(log: "Generated Responses:")
                        Log.debug(log: "\(generatedResponses)")
                        Log.debug(log: "Queue Remaining (FAIL):")
                        Log.debug(log: "\(queuedResponses)")
                    }

                    var str = "There are still \(self.queuedResponses.count) response(s) left in queue:"
                    str += "\n\(self.queuedResponses)"
                    return str
                }
            }
        }

        public func send(_ request: URLRequest,
                         sessionType: MobileCore.Network.SessionType,
                         delay: TimeInterval,
                         _ handler: @escaping (Result<MobileCore.HTTP.Response, Error>) -> Void) {
            guard let response = self.generateResponse(request) else {
                testCase.failTest("No response generated by MockHTTPService for request: \(request).")
                return
            }
            if shouldLog {
                print("MockHTTPService: Dequeueing response:")
                print("\(response)")
            }

            guard assert(request: request, matches: response) else {
                return
            }

            self.generatedResponses.append(response)

            if let error = response.error {
                handler(.failure(error))
            } else {
                handler(.success(MobileCore.HTTP.Response(value: response.data, response: response.urlResponse.response)))
            }

        }

        public func send(_ request: URLRequest,
                         sessionType: MobileCore.Network.SessionType,
                         _ handler: @escaping (Result<MobileCore.HTTP.Response, Error>) -> Void) {
            send(request, delay: 0, handler)
        }

        public func queue(response: Response) {
            queuedResponses.append(response)
        }

        public func queue(responses: [Response]) {
            responses.forEach { self.queue(response: $0)}
        }

        public func cancelRequests() {
            //nothing to do
        }

        public func runRequest(responses: [Mock.Core.HTTP.Response], run: (() -> Void)) {
            queue(responses: responses)
            run()
            waitForRequestQueueToComplete()
        }

        // MARK: - Helpers

        private func assert(request: URLRequest, matches response: Response) -> Bool {
            if let searchTxt = response.requestUrlMustContainString {
                let urlAbsoluteString = request.url!.absoluteString
                if !urlAbsoluteString.contains(find: searchTxt) {
                    XCTFail(
                        """
                        Queued Response was expecting to be issued to request matching \(searchTxt).
                        However actual request was \(urlAbsoluteString)"
                        """
                    )
                    return false
                }
            }
            return true
        }

        public var description: String {
            return "MockHTTPService. Queue Count = [\(queuedResponses)]"
        }
    }
}
