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

    public static func configure(responseHandler: CoreResponseHandler?) {
        var networkService: CoreNetworkService = MobileCore.Injection.Service.network.injectedObject()
        networkService.responseHandler = responseHandler ?? ResponseHandler()
    }

    open class Service: BaseNetworkSpinnerConsumer, CoreNetworkService {
        public weak var responseHandler: CoreResponseHandler!

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
                                    self.responseHandler.handle(request: request, response: response, handler)
                                case let .failure(error):
                                    let error = self.responseHandler.handleError(request: request, response: nil, error: error as NSError)
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
    }
}
