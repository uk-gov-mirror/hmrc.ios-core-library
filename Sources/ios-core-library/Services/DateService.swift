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

public protocol DateService {
    var currentDate: Date { get }
    var utcTimeZone: String { get }
}

extension MobileCore.Date {
    open class Service: DateService {
        public var currentDate: Date {
            return Date()
        }

        private lazy var formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "xxx"
            return formatter
        }()

        public var utcTimeZone: String {
            return formatter.string(from: currentDate)
        }
    }
}
