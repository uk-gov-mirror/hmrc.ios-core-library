fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios tag_release
```
fastlane ios tag_release
```
Create a new tagged release of this library plus a synchronised relase of the associated mobile-ios-core-test library.

This will bump the Info.plist versiona, precompile the librarowa, commit and tag the changes, then push up to master.

Example:

`fastlane tag_release tag:1.2.3`


### ios update_dependencies
```
fastlane ios update_dependencies
```
Update dependencies.
### ios check_dependencies
```
fastlane ios check_dependencies
```
Check for outdated carthage dependencies.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
