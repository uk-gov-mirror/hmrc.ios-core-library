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

open class VoidDataPoster<E: Error>: CoreNetworkServiceInjected {
    public init() {}

    open func data(request _: MobileCore.HTTP.RequestBuilder,
                   _: @escaping ((Result<Void, E>) -> Void)) {
        fatalError("Should be subclassed")
    }

    open func cancelRequests() {
        fatalError("Should be subclassed")
    }
}
