[![npm version](https://badge.fury.io/js/cordova-plugin-ios-app-delegate-events.svg)](http://badge.fury.io/js/cordova-plugin-ios-app-delegate-events)

Cordova App Delegate Events Plugin for iOS
==========================================

The purpose of this plugin is to broadcast iOS-specific application delegate events, so that 3rd party plugins can listen to them.

The reason is that iOS applications are only allowed to register one instance of each delegate method so if 2 or more plugins declare an instance of the same delegate method, only one of these will be called at run-time, leading to some plugins failing to function correctly.

This plugin solves this problem by implementing its own instances of supported app delegate methods, then rebroadcasts calls to the method as events via the NSNotificationCenter which multiple other plugins can register to listen for and handle simultaneously.

The instances of app delegate methods defined by this plugin use [method swizzling](https://nshipster.com/method-swizzling/) in case any other plugins define the same delegate methods in order to avoid overwriting them.

As of right now it's possible to add observers for these events:
- [didFinishLaunchingWithOptions][didFinishLaunchingWithOptions]
- [didReceiveLocalNotification][didReceiveLocalNotification]
- [continueUserActivity][continueUserActivity]

Feel free to submit an PR to broadcast additional events.

# Usage

To make use of the app delegate events in your plugin, follow these steps:

## 1. Add and install the plugin as a dependency
Add this plugin as a dependency of your plugin.

```xml
<!-- plugin.xml -->

<dependency id="cordova-plugin-ios-app-delegate-events" />
```

## 2. Add the protocol to the plugin's interface
Indicate your plugin's interest to receive app events by adding the `APPAppEventDelegate` protocol.

### Objective-C plugin

```obj-c
// MyCordovaPlugin.h

#import "APPAppEventDelegate.h"
#import <Cordova/CDVPlugin.h>

@interface APPLocalNotification : CDVPlugin <APPAppEventDelegate>

@implementation MyCordovaPlugin

...

@end
```

### Swift plugin

```obj-c
// MyCordovaPlugin-Bridging-Header.h

#import "APPAppEventDelegate.h"
#import "AppDelegate+APPAppEvent.h"

...

@end
```

```swift
// MyCordovaPlugin.swift

@objc(MyCordovaPlugin) class MyCordovaPlugin: CDVPlugin, APPAppEventDelegate {
...
}

```

## 3. Add observer methods for the delegated events
To add an observer you need to define a method to handle the app delegate event and register it as a listener for that event during plugin initialization.

For example, to receive the `continueUserActivity` event, you'd register a method to handle `UIApplicationContinueUserActivity` events:

### Objective-C plugin

```obj-c
// MyCordovaPlugin.m

#import "AppDelegate+APPAppEvent.h"

@implementation MyCordovaPlugin

- (void)pluginInitialize {
  [[NSNotificationCenter defaultCenter] 
    addObserver:self 
    selector:@selector(myContinueUserActivityHandler:) 
    name:UIApplicationContinueUserActivity object:nil
  ];
}

- (void) myContinueUserActivityHandler:(NSNotification*)notification{
  
     NSUserActivity* userActivity = notification.object;
     
     // Do something with the user activity
}

@end
```

### Swift plugin

```swift
// MyCordovaPlugin.swift

@objc(MyCordovaPlugin) class MyCordovaPlugin: CDVPlugin, APPAppEventDelegate {

    override func pluginInitialize() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(myContinueUserActivityHandler(_:)),
          name: NSNotification.Name(rawValue: UIApplicationContinueUserActivity),
          object: nil
        )
    }
    
    @objc(myContinueUserActivityHandler:) func myContinueUserActivityHandler(_ notification: NSNotification) {
        let userActivity = notification.object as! NSUserActivity
        
        // Do something with the user activity
    }
}

```


# License

This software is released under the [Apache 2.0 License][apache2_license].

© 2024 Working Edge Ltd. All rights reserved
© 2013-2017 appPlant GmbH, Inc. All rights reserved


[didFinishLaunchingWithOptions]: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application?language=objc
[didReceiveLocalNotification]: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622930-application?language=objc
[continueUserActivity]: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623072-application?language=objc
[app_delegate_protocol]: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/
[apache2_license]: http://opensource.org/licenses/Apache-2.0
