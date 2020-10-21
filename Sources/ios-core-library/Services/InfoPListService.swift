//
//  Copyright 2019 HM Revenue & Customs
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public protocol InfoPListService {
    var infoDictionary: [String: Any] {get}
    subscript(name: String) -> Any? {get}
}

extension MobileCore.InfoPList {

    open class Service: InfoPListService {
        public let infoDictionary: [String: Any] = {
            guard !MobileCore.config.unitTests.areRunning else { return [:] }
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
                fatalError("Couldnt get app info from bundle")
            }
            return dict
        }()

        open subscript<T>(name: String) -> T {
            guard let value = infoDictionary[name] as? T else {
                fatalError("Missing \(name) in info.plist")
            }
            return value
        }
    }
}
