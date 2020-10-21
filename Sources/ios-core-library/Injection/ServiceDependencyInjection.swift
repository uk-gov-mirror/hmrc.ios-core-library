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

//Copy and paste boiler plate
//protocol <#ProtocolName#>Injected {}
//extension <#ProtocolName#>Injected {
//    var <#injectedName#>: <#ProtocolName#> { return MobileCore.Injection.Service.<#SomePath#>.injectedObject() }
//}

public protocol JourneyServiceInjected {}
extension JourneyServiceInjected {
    public var journeyService: JourneyService { return MobileCore.Injection.Service.journey.injectedObject() }
}

public protocol ApplicationStateServiceInjected {}
extension ApplicationStateServiceInjected {
    public var applicationState: ApplicationStateService { return MobileCore.Injection.Service.applicationState.injectedObject() }
}

public protocol CoreNetworkServiceInjected {}
extension CoreNetworkServiceInjected {
    public var coreNetworkService: CoreNetworkService { return MobileCore.Injection.Service.network.injectedObject() }
}

public protocol DeviceInfoServiceInjected {}
extension DeviceInfoServiceInjected {
    public var deviceInfo: DeviceInfoService { return MobileCore.Injection.Service.deviceInfo.injectedObject() }
}

public protocol CoreHTTPServiceInjected {}
extension CoreHTTPServiceInjected {
    public var coreHTTPService: CoreHTTPService { return MobileCore.Injection.Service.http.injectedObject() }
}

public protocol InfoPListServiceInjected {}
extension InfoPListServiceInjected {
    public var infoPlist: InfoPListService { return MobileCore.Injection.Service.infoPlist.injectedObject() }
}

public protocol AppInfoServiceInjected {}
extension AppInfoServiceInjected {
    public var appInfo: AppInfoService { return MobileCore.Injection.Service.appInfo.injectedObject() }
}

public protocol DateServiceInjected {}
extension DateServiceInjected {
    public var dateService: DateService { return MobileCore.Injection.Service.date.injectedObject() }
}

public protocol FraudPreventionServiceInjected {}
extension FraudPreventionServiceInjected {
    public var fraudPrevention: FraudPreventionService { return MobileCore.Injection.Service.fraudPrevention.injectedObject() }
}

public protocol NetworkSpinnerInjected {}
extension NetworkSpinnerInjected {
    public var networkSpinner: NetworkSpinner { return MobileCore.Injection.Service.networkSpinner.injectedObject() }
}

public protocol NetworkSpinnerPolicyInjected {}
extension NetworkSpinnerPolicyInjected {
    public var networkSpinnerPolicy: NetworkSpinnerPolicy { return MobileCore.Injection.Service.networkSpinnerPolicy.injectedObject() }
}

public protocol UserDefaultsInjected {}
extension UserDefaultsInjected {
    public var userDefaults: UserDefaultsProtocol { return MobileCore.Injection.Service.userDefaults.injectedObject() }
}

public protocol CertificatePinningInjected {}
extension CertificatePinningInjected {
    public var certificatePinningService: CertificatePinningService { return MobileCore.Injection.Service.certificatePinning.injectedObject() }
}

extension MobileCore.Injection {
    //public static let <#name#> = Injector { return MobileCore.<#Real Class#>.Service() }

    public struct Service {
        public static let http = Injector("HTTPService") { return MobileCore.HTTP.Service() }
        public static let network = Injector("NetworkService") { return MobileCore.Network.Service() }
        public static let journey = Injector("JourneyService") { return MobileCore.Journey.Service() }
        public static let deviceInfo = Injector("DeviceInfoService") { return MobileCore.Device.Info.Service.standard() }
        public static let applicationState = Injector("ApplicationStateService") { return MobileCore.Application.State.Service() }
        public static let infoPlist = Injector("InfoPlistService") { return MobileCore.InfoPList.Service() }
        public static let appInfo = Injector("AppInfoService") { return MobileCore.AppInfo.Service() }
        public static let date = Injector("DateService") { return MobileCore.Date.Service() }
        public static let fraudPrevention = Injector("FraudPreventionService") { return MobileCore.FraudPrevention.Service() }
        public static let networkSpinner = Injector("HTTPService") { return MobileCore.Network.Spinner.Empty() }
        public static let networkSpinnerPolicy = Injector("NetworkSpinnerService") { return MobileCore.Network.Spinner.Policy() }
        public static let userDefaults = Injector("UserDefaultsService") { return UserDefaults() }
        public static let certificatePinning = Injector("CertificatePinningService") { return MobileCore.HTTP.CertificatePinning() }
    }
}
