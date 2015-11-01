//
//  PopRole.m
//  test004Calendar
//
//  Created by 鹏 朱 on 15-8-30.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopRole.h"

#define kRoleCalendarKey @"kRoleCalendarKey"
#define kRoleNameKey @"kRoleNameKey"

@implementation PopRole

@synthesize roleCalendar;
@synthesize roleName;

- (id)initWithCalendar:(EKCalendar *)calendar
{
    if (self = [super init])
    {
        self.roleCalendar = calendar;
        self.roleName = [self roleNameFromCalendarTitle];
    }
    
    return self;
}

- (id)initWithCalendar:(EKCalendar *)calendar WithRoleName:(NSString *)newRoleName
{
    if (self = [super init])
    {
        self.roleCalendar = calendar;
        self.roleName = newRoleName;
    }
    return self;
}

- (NSString *)roleNameFromCalendarTitle
{
    NSArray * componentsOfTitle = [self.roleCalendar.title componentsSeparatedByString:@"-"];
    if ([componentsOfTitle count] < 2) {
        return @"未命名";
    }
    return [componentsOfTitle objectAtIndex:1];
}

- (id)initWithRoleName:(NSString *)newRoleName WithEventStore:(EKEventStore *) eventStore isNewRole: (BOOL *) isNewRole
{
        //读取所有的calendar集
        NSArray * allCalendars = [eventStore calendarsForEntityType:(EKEntityTypeEvent)];
        NSString * newCalendarTitle =[[NSString alloc] initWithFormat:@"Popmundo-%@",newRoleName];
    
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"title matches %@", newCalendarTitle];
        NSArray * filtered = [allCalendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count] == 0) {
            EKCalendar * newCalendar = [EKCalendar calendarForEntityType:(EKEntityTypeEvent) eventStore:eventStore];
            newCalendar.title = newCalendarTitle;
            newCalendar.source = eventStore.defaultCalendarForNewEvents.source;
            
            NSError * calendarError = nil;
            BOOL calendarSavingSuccess = [eventStore saveCalendar:newCalendar commit:YES error:&calendarError];
            if (calendarSavingSuccess) {
                self = [self initWithCalendar:newCalendar WithRoleName:newRoleName];
                *isNewRole = YES;
            }else
            {
                NSAssert(NO, @"创建%@的日历集失败！", newRoleName);
            }

        } else {
            self = [self initWithCalendar:[filtered objectAtIndex:0] WithRoleName:newRoleName];
            *isNewRole = NO;
        }
    
    return self;
    
}

- (BOOL)removeRoleCalendarWithEventStore:(EKEventStore *) eventStore
{
    NSError * calendarError = nil;
    BOOL calendarDeletingSuccess = [eventStore removeCalendar:self.roleCalendar commit:YES error:&calendarError];
    if (calendarDeletingSuccess) {
        self.roleCalendar = nil;
        return YES;
    }else
    {
        return NO;
    }
}



@end
