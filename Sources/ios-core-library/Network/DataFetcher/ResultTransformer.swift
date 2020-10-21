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

open class ResultTransformer<D: Decodable, E: Error> {

    private let errorTransformer: ServiceErrorTransformer<E>
    private let decoder: CoreDecoder<D>

    public init(errorTransformer: ServiceErrorTransformer<E>,
                decoder: CoreDecoder<D> = CoreDecoder<D>()) {
        self.errorTransformer = errorTransformer
        self.decoder = decoder
    }

    func transform(networkResult: Result<MobileCore.HTTP.Response, MobileCore.Network.ServiceError>) -> Result<D, E> {
        let decodedResult = decoder.decode(result: networkResult)
        switch decodedResult {
        case let .success(model):
            return .success(model)
        case let .failure(error):
            return .failure(errorTransformer.transform(from: error))
        }
    }
}
