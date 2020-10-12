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

public protocol NetworkSpinner {
    func show()
    func popActivity()
}

public protocol NetworkSpinnerConsumer: NetworkSpinnerInjected, NetworkSpinnerPolicyInjected {
    func showSpinnerIfRequiredForURL(_ url: URL)
    func hideSpinnerIfRequiredForURL(_ url: URL)
}

enum NetworkSpinnerSubstitution: String {
    case stringMatcher = ".*"
}

public protocol NetworkSpinnerPolicy {
    var suppressedEndpointPaths: [String] { get }
    var extendDelayEndpointPaths: [String] { get }

    func shouldShowSpinnerForURL(_ url: URL) -> Bool
    func shouldExtendSpinnerForURL(_ url: URL) -> Bool

    var dismissDelay: Double { get }
    var extendDelay: Double { get }
}

extension MobileCore.Network {
    public struct Spinner {
        public class Policy: NetworkSpinnerPolicy {
            public let suppressedEndpointPaths: [String]
            public let extendDelayEndpointPaths: [String]

            public let dismissDelay: Double
            public let extendDelay: Double

            public convenience init(dismissDelay: Double = 0.5, extendDelay: Double = 3.0) {
                self.init(
                    suppressedEndpointPaths: [],
                    extendDelayEndpointPaths: [],
                    dismissDelay: dismissDelay,
                    extendDelay: extendDelay
                )
            }

            public init(suppressedEndpointPaths: [String],
                        extendDelayEndpointPaths: [String],
                        dismissDelay: Double = 0.5,
                        extendDelay: Double = 3.0) {
                self.suppressedEndpointPaths = suppressedEndpointPaths
                self.extendDelayEndpointPaths = extendDelayEndpointPaths
                self.dismissDelay = dismissDelay
                self.extendDelay = extendDelay
            }

            public func shouldShowSpinnerForURL(_ url: URL) -> Bool {
                let urlAbsoluteString = url.absoluteString

                return suppressedEndpointPaths.compactMap { path -> String? in
                    let escapedPath = path.replacingOccurrences(of: "/", with: "\\/")
                    let regex = "\(escapedPath)"
                    return urlAbsoluteString.hasRegexMatch(regex, caseSensitive: true) ? path : nil
                }.isEmpty
            }

            public func shouldExtendSpinnerForURL(_ url: URL) -> Bool {
                let url = url.absoluteString
                return !extendDelayEndpointPaths.compactMap { path in
                    return url.contains(path) ? path : nil
                    }.isEmpty
            }
        }

        ///Default injected network spinner. App must supply and inject a concrete instance of NetworkSpinner
        class Empty: NetworkSpinner {
            let todo = "App should call MobileCore.Injection.Service.networkSpinner.inject(...) to inject a concrete instance of network spinner"
            public func show() {
                print("SPINNER SHOW: \(todo)")
            }

            public func popActivity() {
                print("SPINNER POP: \(todo)")
            }
        }
    }
}
