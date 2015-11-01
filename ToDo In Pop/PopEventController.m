//
//  PopEventController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-22.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopEventController.h"

#import "PopRole.h"
#import "PopEvent.h"

#import "NSDate-ExtractDate.h"

@implementation PopEventController

@synthesize eventStore;
@synthesize popRoles;
@synthesize isAccessToEventStoreGranted;

+ (instancetype)popEventControllerInstanceWithEventStore:(EKEventStore *) _eventStore
{
    static PopEventController * core = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        core = [[PopEventController alloc] initWithEventStore:_eventStore];
    });
    
    return core;
}

- (instancetype)initWithEventStore:(EKEventStore *) _eventStore
{
    if (self = [super init]) {
        self.eventStore = _eventStore;
        popRoles = [[NSMutableDictionary alloc] init];
        
        //[self reloadPopRoles];
    }
    return self;
}

- (void) reloadPopRoles
{
    NSArray * allCalendars = [eventStore calendarsForEntityType:(EKEntityTypeEvent)];
    
    NSString * popCalendarTitle = @"popmundo";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", popCalendarTitle];
    NSArray * filtered = [allCalendars filteredArrayUsingPredicate:predicate];
    ekCalendarsForRole = filtered;
    
    [popRoles removeAllObjects];
    for (EKCalendar * tempCal in filtered) {
        PopRole * tempRole = [[PopRole alloc] initWithCalendar:tempCal];
        [popRoles setObject:tempRole forKey:tempCal.title];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoleListReloadPopRoles" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventsForRoleReloadEventsForRole" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventListReloadEvents" object:self];
}

- (NSArray *)allPopRoles
{
    return [popRoles allValues];
}

- (PopRole *)addNewRoleWithRoleName:(NSString *)newRoleName isNewRole: (BOOL *) isNewRole
{
    PopRole * newRole = [[PopRole alloc] initWithRoleName:newRoleName WithEventStore:eventStore isNewRole:isNewRole];
    if (isNewRole) {
        [popRoles setObject:newRole forKey:newRole.roleCalendar.title];
    }
    return newRole;
}

/*- (BOOL)removeRoleCalendar: (PopRole *) role
{
    BOOL result = [role removeRoleCalendarWithEventStore:eventStore];
    if (result) {
        [popRoles removeObjectForKey:role.roleCalendar.title];
    }
    return result;
}*/

- (NSMutableArray * )popEventsForRole: (PopRole *)role ForDate:(NSDate *)date FromXDay:(NSInteger)xDayNumber ToYDay:(NSInteger)yDayNumber WithIdSet:(NSMutableSet *) idsOfEvent
{
    NSArray * ekEvents = [self eventsAccrodingToDate:date StartFrom:xDayNumber EndTo:yDayNumber FromRole:role];
    NSMutableArray * filteredEkEvents = [self filterOutDuplicatedFromEkEventArray:ekEvents WithIdSet:idsOfEvent];
    NSMutableArray * popEvents = [self popEventsFromEkEventArray:filteredEkEvents FromRole:role];
    
    return popEvents;
}

- (NSMutableArray *)popEventsFromEkEventArray:(NSArray *)_EkEvents FromRole:(PopRole *) _popRole
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for (EKEvent *tempEvent in _EkEvents) {
        
        PopEvent * tempPopEvent;
        if (_popRole == nil)
        {
            tempPopEvent = [[PopEvent alloc] initWithEvent:tempEvent];
        }
        else
        {
            tempPopEvent = [[PopEvent alloc] initWithEvent:tempEvent WithPopRole:_popRole];
        }
            
        [result addObject:tempPopEvent];
    }

    return result;
}

- (NSMutableArray *)filterOutDuplicatedFromEkEventArray:(NSArray *)_EkEvents WithIdSet:(NSMutableSet *) idsOfEvent
{
    if (idsOfEvent == nil) {
        idsOfEvent = [[NSMutableSet alloc] init];
    }
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for (EKEvent * tempEvent in _EkEvents) {
        if (![idsOfEvent containsObject:tempEvent.eventIdentifier]) {//过滤id为重复的事件，让留下一条
            [idsOfEvent addObject:tempEvent.eventIdentifier];
            [result addObject:tempEvent];
        }
    }
    return result;
}

- (NSArray *)eventsAccrodingToDate:(NSDate *) date StartFrom:(NSInteger) xDayNumber EndTo: (NSInteger) yDayNumber FromRole:(PopRole *) _popRole
{
    // 创建起始和结束日期
    NSDate * xDay = [date dateAfter:xDayNumber];
    
    NSDate * yDay = [date dateAfter:yDayNumber];
    
    // 用事件库的实例方法创建谓词
    NSPredicate * predicate;
    if (_popRole == nil) {
        predicate = [eventStore predicateForEventsWithStartDate:xDay endDate:yDay calendars:ekCalendarsForRole];
    }else{
        predicate = [eventStore predicateForEventsWithStartDate:xDay endDate:yDay calendars:@[_popRole.roleCalendar]];
    }
    
    // 获取所有匹配该谓词的事件
    NSArray * events = [eventStore eventsMatchingPredicate:predicate];
    return  events;
}

- (BOOL)hasRole:(PopRole *)_role
{
    if ([popRoles objectForKey:_role.roleCalendar.title]) {
        return YES;
    }else{
        return NO;
    }
}

@end
