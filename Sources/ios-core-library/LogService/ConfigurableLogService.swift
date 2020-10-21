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

public struct Log {
    private static let configurableLogService = ConfigurableLogService()

    public static func setup(with services: [LogService] = [], includeConsole: Bool = false) {
        var servicesToUse = services
        if includeConsole {
            servicesToUse.append(ConsoleLogService())
        }
        configurableLogService.add(services: servicesToUse)
    }

    public static func nonFatal(error: Error) {
        configurableLogService.nonFatal(error: error)
    }

    public static func info(message: String) {
        configurableLogService.info(message: message)
    }

    public static func debug(log: String) {
        configurableLogService.debug(log: log)
    }
}

class ConfigurableLogService: LogService {
    private var logServices = [LogService]()

    func add(services: [LogService]) {
        logServices.append(contentsOf: services)
    }

    func nonFatal(error: Error) {
        logServices.forEach {
            $0.nonFatal(error: error)
        }
    }

    func info(message: String) {
        logServices.forEach {
            $0.info(message: message)
        }
    }

    func debug(log: String) {
        logServices.forEach {
            $0.debug(log: log)
        }
    }
}
