//
//  Resl.swift
//  ios-core-library
//
//  Created by Tendai Moffatt on 12/04/2021.
//

import Foundation

public protocol CoreResponseHandler: class {
    func handle(request: MobileCore.HTTP.RequestBuilder,
                response: MobileCore.HTTP.Response,
                attempt: Int,
                _ handler: @escaping (Result<MobileCore.HTTP.Response, MobileCore.Network.ServiceError>) -> Void)
    func handleError(request: MobileCore.HTTP.RequestBuilder,
                     response: MobileCore.HTTP.Response?,
                     attempt: Int,
                     error: NSError) -> MobileCore.Network.ServiceError
}

extension MobileCore.Network {
    open class ResponseHandler: CoreResponseHandler, CoreNetworkServiceInjected {
        weak var auditDelegate: NetworkServiceAuditDelegate!
        weak var analyticsDelegate: NetworkServiceAnalyticsDelegate!
        let errorDomain = "uk.gov.hmrc"

        public init(auditDelegate: NetworkServiceAuditDelegate, analyticsDelegate: NetworkServiceAnalyticsDelegate) {
            self.auditDelegate = auditDelegate
            self.analyticsDelegate = analyticsDelegate
        }
        
        // swiftlint:disable:next cyclomatic_complexity
        open func handle(request: MobileCore.HTTP.RequestBuilder,
                         response: MobileCore.HTTP.Response,
                         attempt: Int,
                         _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            do {
                let urlResponse = response.response!
                let statusCode = urlResponse.statusCode
                let error = NSError(domain: errorDomain, code: statusCode, userInfo: nil)
                trackAuditEventIfRequired(request: request, data: response.value, response: urlResponse)
                switch statusCode {
                case 410:
                    throw self.handle410(request: request, response: response)
                case 200..<400:
                    self.handle200To399(request: request, response: response, handler)
                case 401, 403:
                    try self.handle401And403(request: request, response: response, attempt: attempt, handler)
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
                    throw self.handleError(request: request, response: response, attempt: attempt, error: error)
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
            request: MobileCore.HTTP.RequestBuilder,
            response: MobileCore.HTTP.Response,
            _ handler: @escaping (Result<MobileCore.HTTP.Response, ServiceError>) -> Void) {
            handler(.success(response))
        }

        open func handle401And403(
            request: MobileCore.HTTP.RequestBuilder,
            response: MobileCore.HTTP.Response,
            attempt: Int,
            _ handler: @escaping (Swift.Result<MobileCore.HTTP.Response, ServiceError>) -> Void) throws {
            trackAnalyticEvent(eventCategory: "errors", eventAction: "forbidden", eventLabel: "403 forbidden")
            throw ServiceError.logout
        }

        open func handle404(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response) -> ServiceError {
            return .notFound
        }

        open func handle4XX(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .unrecoverable(error: error)
        }

        open func handle423(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response) -> ServiceError {
            return .mci
        }

        open func handle410(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response) -> ServiceError {
            return .deceased
        }

        ///Shuttering for core (OLD needs to go)
        open func handle503(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response) -> ServiceError {
            let shutteringError = ServiceError.shuttered(ShutteredModel(
                    title: "Sorry, there is a problem with the service", message: "Try again later."))
            return shutteringError
        }

        open func handle521(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response) -> ServiceError {
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

        open func handle500To599(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response, error: NSError) -> ServiceError {
            return .retryable(error: error)
        }

        open func handleError(request: MobileCore.HTTP.RequestBuilder, response: MobileCore.HTTP.Response?, attempt: Int, error: NSError) -> ServiceError {
            switch error.domain {
            case "cfNetworkDomain", "NSURLErrorDomain":
                return ServiceError.internetConnectivityIssue(error: error)
            default:
                return .unrecoverable(error: error)
            }
        }

        // MARK: - Helpers
        open func trackAnalyticEvent(eventCategory: String, eventAction: String, eventLabel: String?, eventValue: NSNumber? = nil) {
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

        open  func trackAuditEventIfRequired(request: MobileCore.HTTP.RequestBuilder, data: Data, response: URLResponse) {
            guard let auditDelegate = auditDelegate else {
                Log.info(message: "No audit delegate setup! Call Network.configure(analyticsDelegate:, auditDelegate:)")
                return
            }
            auditDelegate.trackAuditEventIfRequired(request: request, data: data, response: response)
        }
    }
}
