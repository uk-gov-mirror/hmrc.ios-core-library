
# iOS Core Library

Library for sharing lower level business code between various cross-gov applications.

# Requirements

- iOS 11.0+
- Swift 5.0

# Installation

## Carthage

Carthage is a decentralised dependency manager that builds your dependencies and provides you with binary frameworks. To integrate the core library into your Xcode project using Carthage, specify it in your Cartfile:

```
github "hmrc/ios-core-library"
```

# Usage
Check the [wiki](https://github.com/hmrc/ios-core-library/wiki) with a breakdown on the different helpers avaliable within this library

## Tools

### fastlane

We use [fastlane](https://docs.fastlane.tools/getting-started/ios) to automate tedious tasks such as tagging a new release.

Our fastlane [README](https://github.com/hmrc/ios-core-library/tree/master/fastlane) documents our custom actions.

### SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to enforce Swift style and conventions. Our custom rules can be found in our [.swiftlint.yml](https://github.com/hmrc/ios-core-library/blob/master/.swiftlint.yml).

### Carthage

We use [Carthage](https://github.com/Carthage/Carthage) for dependency management.

- [ ] Add support for SPM

