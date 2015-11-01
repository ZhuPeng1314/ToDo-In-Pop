//
//  AppDelegate.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize eventStore;
@synthesize isAccessToEventStoreGranted;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.eventStore = [[EKEventStore alloc] init];
    self.isAccessToEventStoreGranted = NO;
    [self updateAuthorizationStatusToAccessEventStore];
    
    self.window.tintColor = [UIColor colorWithRed:9.0/256.0 green:99.0/256.0  blue:154.0/256.0  alpha:1.0];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)updateAuthorizationStatusToAccessEventStore
{
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:(EKEntityTypeEvent)];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied:
        {
            self.isAccessToEventStoreGranted = NO;
            NSAssert(NO, @"用户不允许访问日历！");
            break;
        }
        case EKAuthorizationStatusAuthorized:
        {
            self.isAccessToEventStoreGranted = YES;
            break;
        }
        case EKAuthorizationStatusNotDetermined:
        {
            [self.eventStore requestAccessToEntityType:(EKEntityTypeEvent)
                                            completion:^(BOOL granted, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(),^{
                     self.isAccessToEventStoreGranted = granted;
                 });
             }];
            break;
        }
        default:
            break;
    }
}

@end
