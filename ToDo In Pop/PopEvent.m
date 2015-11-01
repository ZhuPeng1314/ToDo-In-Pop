//
//  PopEvent.m
//  test004Calendar
//
//  Created by 鹏 朱 on 15-8-29.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopEvent.h"

#import "PopRole.h"
#import "PopEventController.h"


/*#define kEkEventKey             @"kEkEventKey"
#define kTitleKey               @"kTitleKey"
#define kRoleKey                @"kRoleKey"
#define kPopEventTypeKey        @"kPopEventTypeKey"
#define kStartDateKey           @"kStartDateKey"
#define kRecurrenceIntervalKey  @"kRecurrenceIntervalKey"
#define kRecurrenceTimeUnitKey  @"kRecurrenceTimeUnitKey"*/

@interface NSString (PureInt)

- (BOOL)isPureInt;

@end

@implementation NSString(PureInt)

- (BOOL)isPureInt
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

@end

@interface EKEvent (ClearRecurrenceRule)

- (void) clearRecurrenceRule;
@end

@implementation EKEvent (ClearRecurrenceRule)

- (void) clearRecurrenceRule
{
    NSArray * allRules = self.recurrenceRules;//需要测试循环是否会影响这个数组内部
    if ([allRules count]) {
        for (EKRecurrenceRule * tempRule in allRules) {
            [self removeRecurrenceRule:tempRule];
        }
    }
}

@end

@implementation PopEvent

@synthesize ekEvent;
@synthesize ekCalendar;
@synthesize title;
@synthesize role;
@synthesize popEventType;
@synthesize startDate;
@synthesize recurrenceInterval;
@synthesize recurrenceTimeUnit;
@synthesize customEventTypeName;

/*
 typedef enum {
 EKRecurrenceFrequencyDaily,
 EKRecurrenceFrequencyWeekly,
 EKRecurrenceFrequencyMonthly,
 EKRecurrenceFrequencyYearly
 } EKRecurrenceFrequency;
 */
- (instancetype)initWithEvent: (EKEvent *) event
{
    if (self = [super init]) {
        self.ekEvent = event;
        self.ekCalendar = self.ekEvent.calendar;
        self.title = ekEvent.title;
        self.role = nil;
        self.popEventType = [self popEventTypeFromEventNotes];
        self.startDate = ekEvent.startDate;
        
        if ([ekEvent.recurrenceRules count] > 0) {
            EKRecurrenceRule * recurrenceRuleOfEvent = [ekEvent.recurrenceRules objectAtIndex:0];
            self.recurrenceInterval = recurrenceRuleOfEvent.interval;
            
            switch (recurrenceRuleOfEvent.frequency) {
                case EKRecurrenceFrequencyDaily:
                    if (self.recurrenceInterval % kDayNumberOfPopYear == 0) {
                        self.recurrenceTimeUnit = kPopYear;
                        self.recurrenceInterval = self.recurrenceInterval / kDayNumberOfPopYear;
                    }else{
                        self.recurrenceTimeUnit = kDay;
                    }
                    break;
                case EKRecurrenceFrequencyWeekly:
                    self.recurrenceTimeUnit = kWeek;
                    break;
                case EKRecurrenceFrequencyMonthly:
                    self.recurrenceTimeUnit = kMonth;
                    break;
                default:
                    break;
            }
        }
        else
        {
            self.recurrenceTimeUnit = kNeverRecurrence;
        }
        
        if (popEventType == kCustom) {
            NSArray * separated = [title componentsSeparatedByString:@": "];
            if ([separated count] > 2) {
                self.customEventTypeName = [separated objectAtIndex:2];
            }
            else{
                self.customEventTypeName = title;
            }
        }
    }
    return self;
}

- (void)setRoleWithPopEventController:(PopEventController *)popEventController
{
    if (self.ekEvent.calendar != nil) {
        PopRole * popRole = [popEventController.popRoles objectForKey:self.ekEvent.calendar.title];
        self.role = popRole;
    }
}

- (instancetype)initWithEvent: (EKEvent *) event WithPopRole:(PopRole *) popRole
{
    if (self = [super init]) {
        self.ekEvent = event;
        self.ekEvent.calendar = popRole.roleCalendar; //保持日历集的一致性
        self.ekCalendar = self.ekEvent.calendar;
        self.title = ekEvent.title;
        self.role = popRole;
        self.popEventType = [self popEventTypeFromEventNotes];
        self.startDate = ekEvent.startDate;
        
        if ([ekEvent.recurrenceRules count] > 0) {
            EKRecurrenceRule * recurrenceRuleOfEvent = [ekEvent.recurrenceRules objectAtIndex:0];
            self.recurrenceInterval = recurrenceRuleOfEvent.interval;
            
            switch (recurrenceRuleOfEvent.frequency) {
                case EKRecurrenceFrequencyDaily:
                    if (self.recurrenceInterval % kDayNumberOfPopYear == 0) {
                        self.recurrenceTimeUnit = kPopYear;
                        self.recurrenceInterval = self.recurrenceInterval / kDayNumberOfPopYear;
                    }else{
                        self.recurrenceTimeUnit = kDay;
                    }
                    break;
                case EKRecurrenceFrequencyWeekly:
                    self.recurrenceTimeUnit = kWeek;
                    break;
                case EKRecurrenceFrequencyMonthly:
                    self.recurrenceTimeUnit = kMonth;
                    break;
                default:
                    break;
            }
        }
        else
        {
            self.recurrenceTimeUnit = kNeverRecurrence;
        }
        
        if (popEventType == kCustom) {
            NSArray * separated = [title componentsSeparatedByString:@": "];
            if ([separated count] > 2) {
                self.customEventTypeName = [separated objectAtIndex:2];
            }
            else{
                self.customEventTypeName = title;
            }
        }
    }
    return self;
}

- (PopEventType) popEventTypeFromEventNotes
{
    NSString * notes = self.ekEvent.notes;
    
    if ([notes isPureInt]) {
        NSInteger intNotes = [notes integerValue];
        if (intNotes < kPopEventTypeNumber && intNotes > -1) {
            return intNotes;
        }
        else
        {//notes中并非在0到最大type数之间
            return kCustom;
        }
    }
    else
    {//notes中并非全为数字
        return kCustom;
    }
}

- (NSString *) eventNotesStringFromPopEventType
{
    return [[NSString alloc] initWithFormat:@"%ld", self.popEventType];
}

- (void)eventDataWriteToEkEventWithEventStore:(EKEventStore *)eventStroe
{
    if (self.ekEvent == nil) {
        self.ekEvent = [EKEvent eventWithEventStore:eventStroe];
        
        EKAlarm * alarm1 = [EKAlarm alarmWithRelativeOffset:-3600];
        [ekEvent addAlarm:alarm1];
        EKAlarm * alarm2 = [EKAlarm alarmWithRelativeOffset:-180];
        [ekEvent addAlarm:alarm2];
        //EKAlarm * alarm3 = [EKAlarm alarmWithAbsoluteDate:[startDate dateByAddingTimeInterval:-7200]];
        //EKAlarm * alarm3 = [EKAlarm alarmWithRelativeOffset:-7200];
        //[ekEvent addAlarm:alarm3];
    }
    
    self.ekEvent.calendar = self.role.roleCalendar;
    ekEvent.title = self.title;
    ekEvent.notes = [self eventNotesStringFromPopEventType];
    ekEvent.startDate = self.startDate;
    
    NSDateComponents * endDateComponent = [[NSDateComponents alloc] init];
    endDateComponent.hour = 1;
    NSDate * OneHourAfterStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:endDateComponent toDate:self.startDate options:0];
    ekEvent.endDate = OneHourAfterStartDate;//将结束时间默认设为开始时间的一小时后
    
    if (recurrenceTimeUnit != kNeverRecurrence)
    {
        EKRecurrenceRule * recurrenceRule = nil;
        if (recurrenceTimeUnit == kPopYear) {
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:(EKRecurrenceFrequencyDaily) interval:(self.recurrenceInterval * kDayNumberOfPopYear) end:nil];
        }
        else
        {
            EKRecurrenceFrequency frequency;
            switch (recurrenceTimeUnit) {
                case kDay:
                    frequency = EKRecurrenceFrequencyDaily;
                    break;
                case kWeek:
                    frequency = EKRecurrenceFrequencyWeekly;
                    break;
                case kMonth:
                    frequency = EKRecurrenceFrequencyMonthly;
                    break;
                default:
                    break;
            }
            recurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:(frequency) interval:(self.recurrenceInterval) end:nil];
        }
        

        ekEvent.recurrenceRules = @[recurrenceRule];
    }
    /*else //由于修改重复属性的操作，实际上采用了先删除此事件及以后事件的策略，然后创建新的。所以不存在需要清空recurrenceRules的情况
    {
        [ekEvent clearRecurrenceRule];
    }*/
    
    
}

- (NSString *)stringFromRecurrenceTimeUnit
{
    NSString * result;
    NSArray * array = [self allRecurrenceTimeUnitNames];
    result = [array objectAtIndex:recurrenceTimeUnit];
    return result;
}

- (NSDictionary *) eventAttitudeInfo
{
    static NSDictionary * dic = nil;
    if (dic == nil) {
        NSString * pathOfEventAttributeInfoPlist = [[NSBundle mainBundle] pathForResource:@"EventAttributeInfo" ofType:@"plist"];
        dic = [[NSDictionary alloc] initWithContentsOfFile:pathOfEventAttributeInfoPlist];
    }
    return dic;
}

- (NSArray *)allEventTypeNames
{
    NSDictionary * dic = [self eventAttitudeInfo];
    return [dic objectForKey:@"EventTypeName"];
}

- (NSArray *)allRecurrenceTimeUnitNames
{
    NSDictionary * dic = [self eventAttitudeInfo];
    return [dic objectForKey:@"RecurrenceTimeUnitName"];
}

- (NSString *)stringFromEventType
{
    NSString * result;
    NSArray * array = [self allEventTypeNames];
    result = [array objectAtIndex:popEventType];
    return result;
}

- (BOOL)removeEventWithEventStore:(EKEventStore *) eventStore
{
    NSError * eventError = nil;
    BOOL eventDeletingSuccess = [eventStore removeEvent:ekEvent span:(EKSpanFutureEvents) commit:YES error:&eventError];
    if (eventDeletingSuccess) {
        self.ekEvent = nil;
        return YES;
    }else
    {
        return NO;
    }
}


@end
