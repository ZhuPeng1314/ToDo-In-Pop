//
//  PopEventController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-22.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@class PopRole;
@class PopEvent;

@interface PopEventController : NSObject
{
    EKEventStore * eventStore;
    NSMutableDictionary * popRoles;
    NSArray * ekCalendarsForRole;
    
    BOOL isAccessToEventStoreGranted;
}

@property (strong, nonatomic) EKEventStore * eventStore;
@property (strong, nonatomic) NSMutableDictionary * popRoles;
@property BOOL isAccessToEventStoreGranted;

+ (instancetype)popEventControllerInstanceWithEventStore:(EKEventStore *) _eventStore;
- (void) reloadPopRoles;
- (NSArray *)allPopRoles;
- (PopRole *)addNewRoleWithRoleName:(NSString *)newRoleName isNewRole: (BOOL *) isNewRole;
- (NSMutableArray * )popEventsForRole: (PopRole *)role ForDate:(NSDate *)date FromXDay:(NSInteger)xDayNumber ToYDay:(NSInteger)yDayNumber WithIdSet:(NSMutableSet *) idsOfEvent;
- (BOOL)hasRole:(PopRole *)_role;

@end
