//
//  NSDate-ExtractDate.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-22.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(ExtractDate)

- (NSDate *)extractDate;
- (NSDate *)extractDateAfter:(NSInteger) xDayNumber;
- (NSDate *)dateAfter:(NSInteger) xDayNumber;

@end
