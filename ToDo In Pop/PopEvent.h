//
//  PopEvent.h
//  test004Calendar
//
//  Created by 鹏 朱 on 15-8-29.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@class PopRole;
@class PopEventController;

#define kDayNumberOfPopYear 56
#define kPopEventTypeNumber 6

typedef enum : NSInteger {
    kBirthDay = 0,
    kCustom, //自定义
    kMagicCube, //魔方
    kSecretBook, //秘之书
    kGrinch, //圣诞怪杰
    kGrandparentsPicture //祖母画像
} PopEventType;

typedef enum : NSInteger {
    kDay = 0,
    kWeek,
    kMonth,
    kPopYear, //56 days
    kNeverRecurrence
} PopRecurrenceTimeUnit;

@interface PopEvent : NSObject
{
    EKEvent * ekEvent;
    EKCalendar * ekCalendar;
    
    NSString * title;
    PopRole * role;//人物
    PopEventType popEventType; //事件类型
    NSDate * startDate; //开始时间
    NSInteger recurrenceInterval; //循环间隔数
    PopRecurrenceTimeUnit recurrenceTimeUnit;//循环单位
    
    NSString * customEventTypeName; //自定义的事件类型名称
    
}

@property (strong, nonatomic) EKEvent * ekEvent;
@property (strong, nonatomic) EKCalendar * ekCalendar;
@property (copy, nonatomic) NSString * title;
@property (strong, nonatomic) PopRole * role;//人物
@property PopEventType popEventType; //事件类型
@property (strong, nonatomic) NSDate * startDate; //开始时间
@property NSInteger recurrenceInterval; //循环间隔数
@property PopRecurrenceTimeUnit recurrenceTimeUnit;//循环单位
@property (copy, nonatomic) NSString * customEventTypeName; //自定义的事件类型名称

- (instancetype)initWithEvent: (EKEvent *) event;
- (instancetype)initWithEvent: (EKEvent *) event WithPopRole:(PopRole *) popRole;
- (void)eventDataWriteToEkEventWithEventStore:(EKEventStore *)eventStroe;


- (NSArray *)allEventTypeNames;
- (NSArray *)allRecurrenceTimeUnitNames;

- (NSString *)stringFromEventType;
- (NSString *)stringFromRecurrenceTimeUnit;

- (BOOL)removeEventWithEventStore:(EKEventStore *) eventStore;

- (void)setRoleWithPopEventController:(PopEventController *)popEventController;


@end
