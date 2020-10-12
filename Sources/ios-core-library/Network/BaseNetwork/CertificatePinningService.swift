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
import TrustKit

public protocol CertificatePinningService {
    func enableCertificatePinning(using pinningModels: [MobileCore.HTTP.CertificatePinning.Model])
    //swiftlint:disable:next line_length
    func validate(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

extension MobileCore.HTTP {
    public class CertificatePinning: CertificatePinningService {

        public struct Model {
            let url: String
            let publicKeys: [String]
            var includeSubdomains = true
            var enforcePinning = true
        }

        private var certificatePinningEnabled = false

        private func initCertificatePinning(domains: [String: [String: Any]]) {
            #if PROD
            TrustKit.initSharedInstance(withConfiguration: [
                kTSKPinnedDomains: domains
            ])
            #endif
        }

        public func enableCertificatePinning(using pinningModels: [Model]) {
            certificatePinningEnabled = true

            let domains = pinningModels.reduce([String: [String: Any]]()) { (result, next) -> [String: [String: Any]] in
                var result = result

                result[next.url] = [
                    kTSKIncludeSubdomains: next.includeSubdomains,
                    kTSKEnforcePinning: next.enforcePinning,
                    kTSKPublicKeyHashes: next.publicKeys
                ]

                return result
            }

            initCertificatePinning(domains: domains)
        }

        //swiftlint:disable:next line_length
        public func validate(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let performDefaultHandling = URLSession.AuthChallengeDisposition.performDefaultHandling

            #if PROD

            if certificatePinningEnabled {
                let validator = TrustKit.sharedInstance().pinningValidator
                if !validator.handle(challenge, completionHandler: completionHandler) {
                    completionHandler(performDefaultHandling, nil)
                }
            } else {
                completionHandler(performDefaultHandling, nil)
            }

            #else
            completionHandler(performDefaultHandling, nil)
            #endif
        }
    }
}
