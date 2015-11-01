//
//  AppDelegate.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    EKEventStore * eventStore;
    BOOL isAccessToEventStoreGranted;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) EKEventStore * eventStore;
@property BOOL isAccessToEventStoreGranted;


@end

