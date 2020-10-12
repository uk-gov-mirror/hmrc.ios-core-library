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

///Prints the prefix, followed by the description of self + its memory address
public func log(object: AnyObject, prefix: String) {
    #if DEBUG || ADHOC || LOCAL_DEVICE || LOCAL_SIMULATOR
    Log.debug(log: objectToString(object, prefix: prefix))
    #endif
}

#if DEBUG || ADHOC || LOCAL_DEVICE || LOCAL_SIMULATOR

///Prints the prefix, followed by the description of obj + its memory address
public func objectToString(_ object: AnyObject, prefix: String) -> String {
    let address = MemoryAddress(of: object)
    return "\(prefix) \(object)<\(address)"
}

public struct MemoryAddress<T>: CustomStringConvertible {

    let intValue: Int

    public var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }

    // for structures
    public init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
    }

    public func toString(prefix: String) -> String {
        return "\(prefix) \(self)"
    }
}

extension MemoryAddress where T: AnyObject {

    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
    }
}

#endif
