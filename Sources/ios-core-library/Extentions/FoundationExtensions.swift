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

extension URLComponents {

    public func queryItemsEqual(_ otherComponents: URLComponents, names: [String] = []) -> Bool {
        if let expectedQueryItems = queryItems, let actualQueryItems = otherComponents.queryItems {
            // First, filter out parameters that are undesired for checking
            let filteredExpectedQueryItems: [URLQueryItem]
            let filteredActualQueryItems: [URLQueryItem]

            if !names.isEmpty {
                filteredExpectedQueryItems = expectedQueryItems.filter { names.contains($0.name) }
                filteredActualQueryItems = actualQueryItems.filter { names.contains($0.name) }
            } else {
                filteredExpectedQueryItems = expectedQueryItems
                filteredActualQueryItems = actualQueryItems
            }

            // If one of the URLs is missing at least one query item then they don't match
            if filteredExpectedQueryItems.count != filteredActualQueryItems.count {
                return false
            }

            // Compare the parameters pairwise and then check if they all matched
            let match = Array(zip(filteredExpectedQueryItems, filteredActualQueryItems))
                .map { pair in return pair.0.value == pair.1.value }
                .allSatisfy { $0 == true }

            return match
        }

        return false
    }

}

extension String {

    public subscript (range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: range.upperBound - range.lowerBound)

        return String(self[startIndex ..< endIndex])
    }

    /**
       Find the index of a character in a string and return that position.

       - parameter character: The character to find in the string

       - returns: The Int index of the string or nil if not found
    */
    public func indexOfCharacter(_ character: Character) -> Int? {
        if let idx = self.firstIndex(of: character) {
            return self.distance(from: self.startIndex, to: idx)
        }
        return nil
    }

    /**
       Extract the initial substring up to the index.
     
       - parameter index: The index of the character to cut the string off at
     
       - returns: The string up to the specified index.
    */
    public func substringToIndex(_ index: Int) -> String {
        if index >= self.count {
            return self
        }
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }

    /**
        Inserts a string into an existing one and returns the resulting string
        after the insert is performed.
        
        - parameter toInsert: The string to insert
        - parameter existingString: A string which `toInsert` will be injected in
        - parameter range: The location data of where `toInsert` will be injected into `existingString`
        
        - returns: The result string after the insert is performed
    */
    public static func insertString(_ toInsert: String,
                                    into existingString: String?,
                                    withRange range: NSRange) -> String {
        let originalString = existingString ?? ""
        let leftSideIndex = originalString.index(originalString.startIndex, offsetBy: range.location)
        let leftSide = String(originalString[..<leftSideIndex])
        let rightSide = String(originalString[leftSideIndex...])
        return (leftSide + toInsert) + rightSide
    }

    /**
        Create a Swift-style Range from an NSRange (which is provided from 
        UITextField delegate methods).
    */
    public func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex) else { return nil }
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) { //swiftlint:disable:this identifier_name
            return from ..< to
        }
        return nil
    }

    /**
        Creates a string with a specified separator every group of characters.
        Eg. Given string: "111122223333", if separator: "-" and groupSize: "4" 
        were specified, the resulting string would be: "1111-2222-3333"
        
        - parameter separator: The separator to use for each subgroup of substrings
        - parameter groupSize: The size of the "group" of substrings to be separated by the separator
        
        - returns: A formatted string of separated subgroups as specified
    */
    public func stringByAddingSeparator(_ separator: String, usingGrouping groupSize: Int) -> String {
        let stringWithAddedSeparators = NSMutableString()
        for index in 0..<self.lengthOfBytes(using: String.Encoding.utf8) {
            if (index > 0) && (index % groupSize == 0) {
                stringWithAddedSeparators.append(separator)
            }
            let characterIndex = self.index(self.startIndex, offsetBy: index)
            let characterToAdd = self[characterIndex]
            stringWithAddedSeparators.append("\(characterToAdd)")
        }
        return stringWithAddedSeparators as String
    }

    /**
        Creates a new string by inserting a specified string using the provided
        range data
        
        - parameter string: The string to inject
        - parameter range: Range data that will dictate the position in the string the injection will occur
        
        - returns: The resulting string after the injection
    */
    public func stringByInsertingString(_ string: String, withRange range: Range<String.Index>) -> String {
        let leftSplit = String(self[..<range.lowerBound])
        let rightSplit = String(self[range.upperBound...])
        let resultString = "\(leftSplit)\(string)\(rightSplit)"
        return resultString
    }

    /**
        Removes all characters from the string that are not part of the 
        specified character set.
        
        - parameter characterSet: The set of characters that are allowed
        
        - returns: A string that contains only the characters from the specified character set
    */
    public func stringWithOnlyCharactersFromSet(_ characterSet: CharacterSet) -> String {
        let unwantedCharacterSet = characterSet.inverted
        return self.components(separatedBy: unwantedCharacterSet).joined(separator: "")
    }

    /**
        Checks if the string contains characters that aren't part of the 
        specified (allowed) set.
        
        - parameter characterSet: The set of characters that are allowed
        
        - returns: True if the original string contains unwanted characters, false otherwise
    */
    public func containsCharactersNotInSet(_ characterSet: CharacterSet) -> Bool {
        let stringWithUnwantedCharacters = stringWithOnlyCharactersFromSet(characterSet.inverted)
        return stringWithUnwantedCharacters.lengthOfBytes(using: String.Encoding.utf8) > 0
    }

    /**
        Extracts matches from the string using the provided RegEx
    */
    public func matchesForRegex(_ regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let bridgedString = NSString(string: self)
            let results = regex.matches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: bridgedString.length)
            )
            return results.map { bridgedString.substring(with: $0.range) }
        } catch {
            return []
        }
    }

    /**
     Extracts capture groups from the string using the provided RegEx
     */
    public func capturedGroups(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        return results.map { result in
            if result.numberOfRanges >= 2 {
                return result.range(at: 1).location != NSNotFound ? nsString.substring(with: result.range(at: 1)) : ""
            } else {
                return ""
            }
        }
    }

    /**
        Checks to see if the string matches the provided RegEx
     
         - parameter regex: The regular expression to use for matching
         - paramter caseSensitive: Should the regex match consider character casing?

         - returns: True if there's a match, false otherwise
     */
    public func hasRegexMatch(_ regex: String, caseSensitive: Bool = true) -> Bool {
        var options: NSString.CompareOptions = .regularExpression
        if !caseSensitive {
            options.insert(.caseInsensitive)
        }
        return self.range(of: regex, options: options, range: nil, locale: nil) != nil
    }

    public func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }

    public func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
