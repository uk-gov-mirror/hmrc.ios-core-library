//
//  Copyright 2020 HM Revenue & Customs
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
public struct MobileCore {
    private static var _config: Configuration?

    ///Must be setup by main target or crash
    public static var config: Configuration {
        get {
            guard let config = _config else {
                // swiftlint:disable:next line_length
                fatalError("Main target must call configure library parameters by passing a valid Configuration instance to MobileCore.config property")
            }
            return config
        } set {
            _config = newValue
        }
    }

    public struct Injection {
        public static var injectors = [String: ResettableInjector]()
        ///Fired after injectors are initialised and reset. Useful for configuring injected instances
        public static var initialised: (() -> Void)!
        public static func initialise() {

            //Allow third party code to initialise
            Injection.initialised?()
        }
    }
    public struct Network { }

    public struct HTTP { }
    public struct InfoPList { }
    public struct AppInfo { }
    public struct FraudPrevention { }
    public struct Application {
        public struct State { }
    }
    public struct Journey { }
    public struct Device {
        public struct Info { }
    }
    public struct Date { }
}
