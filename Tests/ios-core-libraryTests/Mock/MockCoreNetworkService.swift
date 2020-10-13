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

import XCTest
import Foundation
import ios_core_library

open class MockCoreNetworkService: MobileCore.Network.Service {
    public var dataRequestCalled = false
    public var lastDataRequest: MobileCore.HTTP.RequestBuilder? {
        return dataRequests.last
    }
    public var dataRequests = [MobileCore.HTTP.RequestBuilder]()
    public var data: Data?
    public var error: MobileCore.Network.ServiceError?

    public func mockUnrecoverableError(statusCode: Int) {
        error = MobileCore.Network.ServiceError.unrecoverable(error: NSError(domain: "", code: statusCode, userInfo: nil))
    }

    public func mockRetryableError(statusCode: Int) {
        error = MobileCore.Network.ServiceError.retryable(error: NSError(domain: "", code: statusCode, userInfo: nil))
    }

    override open func data(request: MobileCore.HTTP.RequestBuilder,
                            sessionType: MobileCore.Network.SessionType,
                            _ handler: @escaping (Result<MobileCore.HTTP.Response, MobileCore.Network.ServiceError>) -> Void) {

        dataRequestCalled = true
        dataRequests.append(request)
        if let error = error {
            handler(.failure(error))
        } else if let data = data {
            handler(.success(MobileCore.HTTP.Response(value: data, response: nil)))
        } else {
            handler(.success(MobileCore.HTTP.Response(value: Data(), response: nil)))
        }
    }
}
