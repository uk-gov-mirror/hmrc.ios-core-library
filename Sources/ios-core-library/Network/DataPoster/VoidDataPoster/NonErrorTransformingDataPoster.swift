/*
 * Copyright 2020 HM Revenue & Customs
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

public class NonErrorTransformingDataPoster: VoidDataPoster<MobileCore.Network.ServiceError> {

    private let resultTransformer: VoidResultTransformer<MobileCore.Network.ServiceError>

    init(resultTransformer: VoidResultTransformer<MobileCore.Network.ServiceError>) {
        self.resultTransformer = resultTransformer
    }

    public override func data(request: MobileCore.HTTP.RequestBuilder,
                              _ handler: @escaping ((Result<Void, MobileCore.Network.ServiceError>) -> Void)) {
        coreNetworkService.data(request: request) { [weak self] networkResult in
            guard let self = self else {
                Log.nonFatal(error: NSError(domain: "self is nil in NonErrorTransformingDataPoster callback",
                                                code: 0))
                return
            }
            handler(self.resultTransformer.transform(networkResult: networkResult))
        }
    }

    public override func cancelRequests() {
        coreNetworkService.cancelRequests()
    }
}
