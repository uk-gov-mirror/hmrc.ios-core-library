//
//  Resl.swift
//  ios-core-library
//
//  Created by Tendai Moffatt on 12/04/2021.
//

import Foundation

protocol CoreResponseHandler {
    func handle(request: URLRequest,
                     response: MobileCore.HTTP.Response,
                     _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void)
//    func handle200To399(request: URLRequest,
//                        response: MobileCore.HTTP.Response,
//                        _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void)
//    func handle401And403(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    func handle404(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    func handle4XX(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError
//    func handle423(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    func handle410(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    ///Shuttering for core (OLD needs to go)
//    func handle503(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    func handle521(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError
//    func handle500To599(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError
//    func handleAnyOtherError(request: URLRequest, response: MobileCore.HTTP.Response?, error: NSError) -> ServiceError
}

extension MobileCore.Network {
    open class ResponseHandler: CoreResponseHandler {

        // swiftlint:disable:next cyclomatic_complexity
        open func handle(request: URLRequest,
                         response: MobileCore.HTTP.Response,
                         _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            do {
                let urlResponse = response.response!
                let statusCode = urlResponse.statusCode
                let error = NSError(domain: errorDomain, code: statusCode, userInfo: nil)
                self.trackAuditEventIfRequired(request: request, data: response.value, response: urlResponse)
                switch statusCode {
                case 410:
                    throw self.handle410(request: request, response: response)
                case 200..<400:
                    self.handle200To399(request: request, response: response, handler)
                case 401, 403:
                    throw self.handle401And403(request: request, response: response)
                case 404:
                    throw self.handle404(request: request, response: response)
                case 423:
                    throw self.handle423(request: request, response: response)
                case 400..<500:
                    throw self.handle4XX(request: request, response: response, error: error)
                case 503:
                    throw self.handle503(request: request, response: response)
                case 521:
                    throw self.handle521(request: request, response: response)
                case 500...599:
                    throw self.handle500To599(request: request, response: response, error: error)
                default:
                    throw self.handleAnyOtherError(request: request, response: response, error: error)
                }
            } catch {
                if let error = error as? ServiceError {
                    handler(.failure(error))
                } else {
                    handler(.failure(ServiceError.unrecoverable(error: error)))
                }
            }
        }

        open func handle200To399(
                request: URLRequest,
                response: MobileCore.HTTP.Response,
                _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            handler(.success(response))
        }

        open func handle401And403(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            trackAnalyticEvent(eventCategory: "errors", eventAction: "forbidden", eventLabel: "403 forbidden")
            return .logout
        }

        open func handle404(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .notFound
        }

        open func handle4XX(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .unrecoverable(error: error)
        }

        open func handle423(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .mci
        }

        open func handle410(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            return .deceased
        }

        ///Shuttering for core (OLD needs to go)
        open func handle503(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
            let shutteringError = ServiceError.shuttered(ShutteredModel(
                    title: "Sorry, there is a problem with the service", message: "Try again later."))
            return shutteringError
        }

        open func handle521(request: URLRequest, response: MobileCore.HTTP.Response) -> ServiceError {
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

        open func handle500To599(request: URLRequest, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .retryable(error: error)
        }

        open func handleAnyOtherError(request: URLRequest, response: MobileCore.HTTP.Response?, error: NSError) -> ServiceError {
            switch error.domain {
            case "cfNetworkDomain", "NSURLErrorDomain":
                return ServiceError.internetConnectivityIssue(error: error)
            default:
                return .unrecoverable(error: error)
            }
        }
    }
}
