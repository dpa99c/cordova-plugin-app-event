/*
 * Copyright (c) 2024 by Working Edge Ltd. All rights reserved.
 * Copyright (c) 2013-2017 by appPlant GmbH. All rights reserved.
 *
 * @APPPLANT_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apache License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://opensource.org/licenses/Apache-2.0/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPPLANT_LICENSE_HEADER_END@
 */

#import "AppDelegate+APPAppEvent.h"
#import "CDVPlugin+APPAppEvent.h"

#import <Availability.h>
#import <objc/runtime.h>

NSString* const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString* const UIApplicationRegisterUserNotificationSettings = @"UIApplicationRegisterUserNotificationSettings";
NSString* const UIApplicationContinueUserActivity = @"UIApplicationContinueUserActivity";

@implementation AppDelegate (APPAppEvent)

#pragma mark -
#pragma mark Life Cycle

/**
 * Its dangerous to override a method from within a category.
 * Instead we will use method swizzling.
 */
+ (void) load
{
  [self exchange_methods:@selector(application:didFinishLaunchingWithOptions:)
                swizzled:@selector(swizzled_application:didFinishLaunchingWithOptions:)];

  [self exchange_methods:@selector(application:didReceiveLocalNotification:)
                swizzled:@selector(swizzled_application:didReceiveLocalNotification:)];

  [self exchange_methods:@selector(application:continueUserActivity:restorationHandler:)
                swizzled:@selector(swizzled_application:continueUserActivity:restorationHandler:)];
}

#pragma mark -
#pragma mark Delegate

/**
 * Repost finish of app launching
 */
- (void) swizzled_application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions
{
  // re-post (broadcast)
  [self postNotificationName:UIApplicationDidFinishLaunchingNotification object:launchOptions];
  // This actually calls the original method over in AppDelegate
  [self swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
}


/**
 * Repost all local notification using the default NSNotificationCenter so
 * multiple plugins may respond.
 */
- (void)   swizzled_application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
  // re-post (broadcast)
  [self postNotificationName:UIApplicationDidReceiveLocalNotification object:notification];
  // This actually calls the original method over in AppDelegate
  [self swizzled_application:application didReceiveLocalNotification:notification];
}

/**
  * Repost all user activity using the default NSNotificationCenter so
  * multiple plugins may respond.
  */
- (BOOL)swizzled_application:(UIApplication *)application
        continueUserActivity:(NSUserActivity *)userActivity
          restorationHandler:(void (^)(NSArray *))restorationHandler
{
    // re-post (broadcast)
    [self postNotificationName:UIApplicationContinueUserActivity object:userActivity];
    // This actually calls the original method over in AppDelegate
    return [self swizzled_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

#pragma mark -
#pragma mark Core

/**
 * Exchange the method implementations.
 */
+ (void) exchange_methods:(SEL)original swizzled:(SEL)swizzled
{
    class_addMethod(self, original, (IMP) defaultMethodIMP, "v@:");

    Method original_method = class_getInstanceMethod(self, original);
    Method swizzled_method = class_getInstanceMethod(self, swizzled);

    method_exchangeImplementations(original_method, swizzled_method);
}

#pragma mark -
#pragma mark Helper

void defaultMethodIMP (id self, SEL _cmd) { /* nothing to do here */ }

/**
 * Broadcasts the notification to all listeners.
 */
- (void) postNotificationName:(NSString*)aName object:(id)anObject
{
    [[NSNotificationCenter defaultCenter] postNotificationName:aName
                                                        object:anObject];
}

@end
