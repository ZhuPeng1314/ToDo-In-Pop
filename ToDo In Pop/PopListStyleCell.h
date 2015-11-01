//
//  PopListStyleCell.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-11.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopListStyleCell : UITableViewCell
{
    BOOL isOddRow;
    UIColor * oddRowColor;
    UIColor * unoddRowColor;
    UIImageView * highlightImage;
    CGFloat x;
    CGFloat y;
    CGFloat bottomMargin;
    UIView * popListStyleView;
}

@property BOOL isOddRow;
@property (strong, nonatomic) UIColor * oddRowColor;
@property (strong, nonatomic) UIColor * unoddRowColor;
@property (strong, nonatomic) UIImageView * highlightImage;
@property CGFloat x;
@property CGFloat y;
@property CGFloat bottomMargin;
@property CGFloat cellHeight;
@property (strong, nonatomic) UIView * popListStyleView;

- (void) updatePopListStyleView;

@end
