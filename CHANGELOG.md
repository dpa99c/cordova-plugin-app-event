ChangeLog
---------
#### Version 2.0.1 
* fix reference to UIApplicationDidReceiveLocalNotification
#### Version 2.0.0 
- Change plugin ID to `cordova-plugin-ios-app-delegate-events` and maintainer to @dpa99c
- Add support for more app delegate methods: `continueUserActivity`
- Remove support for deprecated delegate method [didRegisterUserNotificationSettings](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623022-application?language=objc)

#### Version 1.2.2 (25.09.2019)
- Fix breaks on cordova-ios 5.x

#### Version 1.2.1 (28.08.2017)
- Fix Package.json not found Cordova 7.0

#### Version 1.2.0 (17.02.2016)
- White-list swizzling through APPAppEventDelegate protocol (#5)
- Finally fixed `EXC_BAD_ACCESS error` (#4)
- Removed usage of `nullable` to prevent build failures

#### Version 1.1.0 (02.01.2016)
- Fixed `EXC_BAD_ACCESS error`

#### Version 1.0.0 (01.01.2016)
- Initial version
