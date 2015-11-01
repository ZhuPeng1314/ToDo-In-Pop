//
//  PopRole.h
//  test004Calendar
//
//  Created by 鹏 朱 on 15-8-30.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface PopRole : NSObject
{
    EKCalendar * roleCalendar;
    NSString * roleName;
}

@property (strong, nonatomic) EKCalendar * roleCalendar;
@property (copy, nonatomic) NSString * roleName;

- (id)initWithCalendar:(EKCalendar *)calendar;
- (id)initWithCalendar:(EKCalendar *)calendar WithRoleName:(NSString *)newRoleName;
- (id)initWithRoleName:(NSString *)newRoleName WithEventStore:(EKEventStore *) eventStore isNewRole: (BOOL *) isNewRole;
- (BOOL)removeRoleCalendarWithEventStore:(EKEventStore *) eventStore;

@end
