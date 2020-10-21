# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
- Adding `fastlane` release process

## [2.4.6] - 2020-05-15
### Added
- Added request cancellation logic data fetcher and poster classes

## [2.4.5] - 2020-05-13
### Changed
- Updated `VoidDataPoster`, `VoidDataPosterFactory` and `VoidResultTransformer` to be fully subclassable

## [2.4.4] - 2020-05-11
### Changed
- Updated struct name from `HMRCLog` to `Log`

## [2.4.3] - 2020-04-23
- Added full subclassing ability to `ServiceErrorTransformer`
- Added `CaseIterable` protocol to `ServiceError`

## [2.4.2] - 2020-03-31
### Changed
- Updated DeviceKit to version 3.1.0

## [2.4.1] - 2020-03-26
### Changed
- Open data fetcher classes to allow mocking

## [2.4.0] - 2020-03-16
- Added BackgroundDataPoster

## [2.2.3] - 2020-02-12
### Changed
Update default shuttering message
Pin version of TrustKit to 1.6.4

## [2.2.2] - 2020-02-04
### Fixed
- Fix findFirstNestedView(ofType:containingText) so that does what it's supposed to!

## [2.2.1] - 2020-01-23
### Fixed
- Ensure network calls return on main thread
- Fail gracefully if self is deallocated (which we only expect to happen when running app unit test suite)

## [2.2.0] - 2020-01-23
### Added
- Add mainThread helper (and use it in BaseNetworkService)

## [2.1.1] - 2019-12-05

### Added
- Exposing DataFetcher functions

## [2.1.0] - 2019-12-05
### Added
- Added Network DataFetcher

## [2.0.0] - 2019-11-29
### Security
- Removed incorrect certificate for tax.service.gov.uk

## [1.5.0] - 2019-11-28
### Security
- Added new certificate to pin against

### Removed
- Removed support for iOS 9

## [1.4.20] - 2019-11-22
### Changed
- Adding `privacyVersion` accessor for Info.plist

## [1.4.17] - 2019-09-12
### Changed
- Make APIService initialiser public

## [1.4.16] - 2019-09-03
### Fixed
- Switched to forked TrustKit to bring back support for iOS 9

## [1.4.15] - 2019-08-20
### Changed
- Add `includeConsole` parameter to HMRCLog setup (which defaults to false)

## [1.4.11] - 2019-07-19
### Changed
- Updated to use new logging

### Removed
- Removed 'String+StaticString' extension

## [1.4.10] - 2019-07-19
### Changed
- Simplify logging

## [1.4.9] - 2019-07-19
### Changed
- Output console logs for DEBUG, ADHOC, LOCAL DEVICE && LOCAL SIMULATOR build configs

## [1.4.8] - 2019-07-18
### Added
- Add LogService

## [1.4.6] - 2019-07-15
### Changed
- Changed 'Release' build config to 'Release-Prod' to match main app

## [1.4.3] - 2019-07-08
### Changed
- HTTPRequestBuilder `delete` method now ensure body is empty

## [1.4.2] - 2019-07-04
### Changed
- HTTPRequestBuilder now supports `delete` method
Made core request builder properties publicly readable

## [1.4.1] - 2019-07-03
### Changed
- HTTPRequestBuilder now supports `delete` method

## [1.3.6] - 2019-05-07
### Changed
- Use CoreTesthelpers to avoid conflict

## [1.3.5] - 2019-05-07
### Changed
- Use git submodule for MobileCoreTestShared dependence
- Improve spinner clearing
- Fix SwiftLint warnings

## [1.3.4] - 2019-05-03
### Fixed
- Fixed `hasStartedNewJourney` in `JourneyService` when running UITests.

## [1.3.3] - 2019-05-03
### Fixed
- Made `ProcessInfo` public

## [1.3.2] - 2019-05-03
### Fixed
- Ensure spinner is hidden after network error.

## [1.3.1] - 2019-05-03
### Fixed
- Moved `ProcessInfo` structs from main app to core.

## [1.3.0] - 2019-05-03
### Changed
- (Re)Added mocked `journeyID` when running UI tests

## [1.2.5] - 2019-05-01
Initial release!
