//
//  NSDate-ExtractDate.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-22.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "NSDate-ExtractDate.h"

@implementation NSDate(ExtractDate)

- (NSDate *)extractDate
{
    //get seconds since 19703
    NSTimeInterval interval = [self timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    //calculate integer type of days
    NSInteger allDays = interval / daySeconds;
    
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}

- (NSDate *)extractDateAfter:(NSInteger) xDayNumber
{
    //get seconds since 19703
    NSTimeInterval interval = [self timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    //calculate integer type of days
    NSInteger allDays = interval / daySeconds + xDayNumber;
    
    return [NSDate dateWithTimeIntervalSince1970:allDays * daySeconds];
}

- (NSDate *)dateAfter:(NSInteger) xDayNumber
{
    NSTimeInterval interval = [self timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    NSInteger newInterval = interval + xDayNumber * daySeconds;
    return [NSDate dateWithTimeIntervalSince1970:newInterval];
}

@end
