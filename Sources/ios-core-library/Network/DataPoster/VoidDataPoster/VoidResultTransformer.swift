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

public class VoidResultTransformer<E: Error> {
    private let errorTransformer: ServiceErrorTransformer<E>

    public init(errorTransformer: ServiceErrorTransformer<E>) {
        self.errorTransformer = errorTransformer
    }

    open func transform(networkResult: Result<MobileCore.HTTP.Response, MobileCore.Network.ServiceError>) -> Result<Void, E> {
        switch networkResult {
        case .success:
            return .success(())
        case let .failure(error):
            return .failure(errorTransformer.transform(from: error))
        }
    }
}
