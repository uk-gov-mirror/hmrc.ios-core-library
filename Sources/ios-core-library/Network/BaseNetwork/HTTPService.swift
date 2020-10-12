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

public typealias HTTPHandler = ((Result<MobileCore.HTTP.Response, Error>) -> Void)

public protocol CoreHTTPService {
    var urlSession: URLSession { get }
    func send(_ request: URLRequest,
              sessionType: MobileCore.Network.SessionType,
              delay: TimeInterval,
              _ handler: @escaping HTTPHandler)
    func cancelRequests()
}

public extension CoreHTTPService {

    func send(_ request: URLRequest,
              sessionType: MobileCore.Network.SessionType = .default,
              delay: TimeInterval = 0,
              _ handler: @escaping HTTPHandler) {
        send(request, sessionType: sessionType, delay: delay, handler)
    }
}

extension MobileCore.HTTP {

    public struct Response {
        public let value: Data
        public let response: HTTPURLResponse?

        public init(value: Data, response: HTTPURLResponse?) {
            self.value = value
            self.response = response
        }
    }

    public enum Method: String {
        case get
        case post
        case put
        case delete
    }

    open class Service: NSObject, CoreHTTPService, URLSessionDelegate, CertificatePinningInjected {

        private let sessionService = MobileCore.Network.SessionConfigurationService()

        public lazy var urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)

        public func send(_ request: URLRequest,
                         sessionType: MobileCore.Network.SessionType,
                         _ handler: @escaping HTTPHandler) {
            send(request, sessionType: sessionType, delay: 0, handler)
        }

        open func send(_ request: URLRequest,
                       sessionType: MobileCore.Network.SessionType,
                       delay: TimeInterval,
                       _ handler: @escaping HTTPHandler) {
            delayedCall(delay) { [weak self] in
                guard let self = self else { return }
                switch sessionType {
                case .default:
                    self.defaultSessionRequest(request: request, handler: handler)
                case .background:
                    let config = self.sessionService.config(
                            sessionType: sessionType,
                            identifier: UUID().uuidString)
                    self.customSessionRequest(sessionConfiguration: config,
                            request: request)
                default:
                    fatalError("Only `default` & `background` session types supported")
                }
            }
        }

        private func defaultSessionRequest(request: URLRequest, handler: @escaping HTTPHandler) {
            urlSession.dataTask(with: request, completionHandler: { (data, urlResponse, error) in
                if let error = error {
                    handler(.failure(error))
                } else {
                    let response = Response(value: data ?? Data(), response: urlResponse as? HTTPURLResponse)
                    handler(.success(response))
                }
            }).resume()
        }

        private func customSessionRequest(sessionConfiguration: URLSessionConfiguration,
                                          request: URLRequest) {
            let urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
            urlSession.dataTask(with: request).resume()
        }

        open func cancelRequests() {
            urlSession.getAllTasks { (tasks) in
                tasks.forEach { $0.cancel() }
            }
        }

        public func urlSession(
                _ session: URLSession,
                didReceive challenge: URLAuthenticationChallenge,
                completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?)
                -> Void) {
            certificatePinningService.validate(challenge: challenge, completionHandler: completionHandler)
        }

        public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            /*
            We're not managing any completion handlers or callbacks for background tasks.
            Our implementation for now is fire and forget.
            If in the future we need to act on a completion handlers or callback, the functionality can be added
            */
        }
    }
}
