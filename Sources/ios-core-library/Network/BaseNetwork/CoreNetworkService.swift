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
public typealias NetworkHandler = ((Result<MobileCore.HTTP.Response, MobileCore.Network.ServiceError>) -> Void)

public protocol CoreNetworkService {
    var auditDelegate: NetworkServiceAuditDelegate! { get set }
    var analyticsDelegate: NetworkServiceAnalyticsDelegate! { get set }
    var responseHandler: CoreResponseHandler! { get set }

    func data(request: MobileCore.HTTP.RequestBuilder,
              sessionType: MobileCore.Network.SessionType,
              _ handler: @escaping NetworkHandler)
    func cancelRequests()
}

public extension CoreNetworkService {
    func data(request: MobileCore.HTTP.RequestBuilder, _ handler: @escaping NetworkHandler) {
        data(request: request, sessionType: .default, handler)
    }
}
public protocol Endpoint {
    var path: String { get }
}

public protocol NetworkServiceAuditDelegate: class {
    func trackAuditEventIfRequired(request: URLRequest, data: Data, response: URLResponse)
}

public protocol NetworkServiceAnalyticsDelegate: class {
    func trackAnalyticEvent(eventCategory: String, eventAction: String, eventLabel: String?, eventValue: NSNumber?)
}

public protocol NetworkServiceAuthenticationDelegate: class {
    func didReceive401() -> Bool
}

open class APIService: CoreNetworkServiceInjected {
    let shutteredModel: MobileCore.Network.ShutteredModel?

    public init(shutteredModel: MobileCore.Network.ShutteredModel?) {
        self.shutteredModel = shutteredModel
    }
}

extension MobileCore.Network {
    public struct ShutteredModel: Decodable {
        public let title: String
        public let message: String

        public init(title: String, message: String) {
            self.title = title
            self.message = message
        }

        public static let `default` =
            ShutteredModel(title: "Sorry, there is a problem with the service", message: "Try again later.")
    }

    public enum ServiceError: Error, CaseIterable {
        case mci
        case logout
        case retryable(error: Error)
        case notFound
        case deceased
        case unrecoverable(error: Error)
        case shuttered(_ model: ShutteredModel)
        case malformedJSON
        case internetConnectivityIssue(error: Error)

        public static var allCases: [ServiceError] {
            return [mci,
                    logout,
                    retryable(error: NSError()),
                    notFound,
                    deceased,
                    unrecoverable(error: NSError()),
                    shuttered(ShutteredModel.default),
                    malformedJSON,
                    internetConnectivityIssue(error: NSError())]
        }
    }

    public static func configure(analyticsDelegate: NetworkServiceAnalyticsDelegate, auditDelegate: NetworkServiceAuditDelegate, responseHandler: CoreResponseHandler?) {
        var networkService: CoreNetworkService = MobileCore.Injection.Service.network.injectedObject()
        networkService.analyticsDelegate = analyticsDelegate
        networkService.auditDelegate = auditDelegate
        networkService.responseHandler = responseHandler ?? ResponseHandler()
    }

    open class Service: BaseNetworkSpinnerConsumer, CoreNetworkService {
        public weak var auditDelegate: NetworkServiceAuditDelegate!
        public weak var analyticsDelegate: NetworkServiceAnalyticsDelegate!
        public weak var responseHandler: CoreResponseHandler!

        let errorDomain = "uk.gov.hmrc"

//        // swiftlint:disable:next cyclomatic_complexity
//        open func handle(request: URLRequest,
//                         response: MobileCore.HTTP.Response,
//                         _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
//            do {
//                let urlResponse = response.response!
//                let statusCode = urlResponse.statusCode
//                let error = NSError(domain: errorDomain, code: statusCode, userInfo: nil)
//                self.trackAuditEventIfRequired(request: request, data: response.value, response: urlResponse)
//                switch statusCode {
//                case 410:
//                    throw self.handle410(request: request, response: response)
//                case 200..<400:
//                    self.handle200To399(request: request, response: response, handler)
//                case 401, 403:
//                    throw self.handle401And403(request: request, response: response)
//                case 404:
//                    throw self.handle404(request: request, response: response)
//                case 423:
//                    throw self.handle423(request: request, response: response)
//                case 400..<500:
//                    throw self.handle4XX(request: request, response: response, error: error)
//                case 503:
//                    throw self.handle503(request: request, response: response)
//                case 521:
//                    throw self.handle521(request: request, response: response)
//                case 500...599:
//                    throw self.handle500To599(request: request, response: response, error: error)
//                default:
//                    throw self.handleAnyOtherError(request: request, response: response, error: error)
//                }
//            } catch {
//                if let error = error as? ServiceError {
//                    handler(.failure(error))
//                } else {
//                    handler(.failure(ServiceError.unrecoverable(error: error)))
//                }
//            }
//        }

        var pendingRequests = [MobileCore.HTTP.RequestBuilder]()

        open func data(
                request: MobileCore.HTTP.RequestBuilder,
                sessionType: MobileCore.Network.SessionType,
                _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            //need to store a ref to the builder as the build process is async and the method that called data(request:_:) will probably
            //have fallen out of scope by the time this is called
            pendingRequests.append(request)
            request.build { [weak self] (result) in
                guard let self = self else {
                    Log.info(message: "MobileCore data.request failed as self was nil in request.build closure")
                    return
                }
                //now the request has been built, we must remove it from pending requests
                if let index = self.pendingRequests.firstIndex(of: request) {
                    self.pendingRequests.remove(at: index)
                }
                mainThread {
                    switch result {
                    case let .success(request):
                        self.showSpinnerIfRequiredForURL(request.url!)
                        self.coreHTTPService.send(request, sessionType: sessionType, { (result) in
                            mainThread {
                                self.hideSpinnerIfRequiredForURL(request.url!)
                                switch result {
                                case let .success(response):
                                    self.handle(request: request, response: response, handler)
                                case let .failure(error):
                                    let error = self.handleAnyOtherError(request: request, response: nil, error: error as NSError)
                                    handler(.failure(error))
                                }
                            }
                        })
                    case let .failure(error):
                        let error = ServiceError.unrecoverable(error: error)
                        handler(.failure(error))
                    }
                }
            }
        }

        open func cancelRequests() {
            coreHTTPService.cancelRequests()
        }

        // MARK: - Case Handling

        func handle200To399(
                request: URLRequest,
                response: MobileCore.HTTP.Response,
                _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            handler(.success(response))
        }

        func handle401And403(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            trackAnalyticEvent(eventCategory: "errors", eventAction: "forbidden", eventLabel: "403 forbidden")
            return .logout
        }

        func handle404(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .notFound
        }

        func handle4XX(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .unrecoverable(error: error)
        }

        func handle423(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .mci
        }

        func handle410(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .deceased
        }

        ///Shuttering for core (OLD needs to go)
        func handle503(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            let shutteringError = ServiceError.shuttered(ShutteredModel(
                    title: "Sorry, there is a problem with the service", message: "Try again later."))
            return shutteringError
        }

        func handle521(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            do {
                var model = try JSONDecoder().decode(ShutteredModel.self, from: response.value)
                let defaultTitle = ShutteredModel.default.title
                let defaultMessage = ShutteredModel.default.message
                let title = model.title.isEmpty ? defaultTitle : model.title
                let message = model.message.isEmpty ? defaultMessage : model.message
                model = ShutteredModel(title: title, message: message)
                let shutteringError = ServiceError.shuttered(model)
                return shutteringError
            } catch {
                return .shuttered(.default)
            }
        }

        func handle500To599(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .retryable(error: error)
        }

        func handleAnyOtherError(request: URLRequest, response: MobileCore.HTTP.Response?, error: NSError) -> ServiceError {
            switch error.domain {
            case "cfNetworkDomain", "NSURLErrorDomain":
                return ServiceError.internetConnectivityIssue(error: error)
            default:
                return .unrecoverable(error: error)
            }
        }

        // MARK: - Helpers
        func trackAnalyticEvent(eventCategory: String, eventAction: String, eventLabel: String?, eventValue: NSNumber? = nil) {
            guard let analyticsDelegate = analyticsDelegate else {
                Log.info(message: "No analytics delegate setup! Call Network.configure(analyticsDelegate:, auditDelegate:)")
                return
            }
            analyticsDelegate.trackAnalyticEvent(
                    eventCategory: eventCategory,
                    eventAction: eventAction,
                    eventLabel: eventLabel,
                    eventValue: eventValue
            )
        }

        private func trackAuditEventIfRequired(request: URLRequest, data: Data, response: URLResponse) {
            guard let auditDelegate = auditDelegate else {
                Log.info(message: "No audit delegate setup! Call Network.configure(analyticsDelegate:, auditDelegate:)")
                return
            }
            auditDelegate.trackAuditEventIfRequired(request: request, data: data, response: response)
        }
    }
}
