//
//  PopListStyleCell.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-11.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopListStyleCell.h"

@implementation PopListStyleCell
@synthesize isOddRow;
@synthesize oddRowColor;
@synthesize unoddRowColor;
@synthesize highlightImage;
@synthesize x;
@synthesize y;
@synthesize bottomMargin;
@synthesize popListStyleView;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    //self.contentView.layer.cornerRadius = 10;
    self.contentView.clipsToBounds = YES;//按照当前视图裁剪子视图，包括裁剪圆角矩形
    
    self.isOddRow = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.backgroundColor = [UIColor clearColor];

    [self initPopListStyleViewRectWithX:5.0f Y:3.0f BottomMargin:3.0f];
    
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
       
        if (highlightImage == nil) {
            self.highlightImage = [[UIImageView alloc] initWithFrame:self.popListStyleView.bounds];
            [self.highlightImage setImage:[UIImage imageNamed:@"popListItemHighlightedBg"]];
        }
        
        //[self insertSubview:highlightImage atIndex:0];
        [self.popListStyleView insertSubview:highlightImage atIndex:0];
        
    }
    else
    {
        //self.backgroundView = nil;
        [highlightImage removeFromSuperview];
        
        [self setIsOddRow:isOddRow];
    }
}

- (BOOL)isOddRow
{
    return isOddRow;
}

- (void)setIsOddRow:(BOOL)_isOddRow
{
    isOddRow = _isOddRow;
    if (isOddRow) {
        if (oddRowColor == nil) {
            oddRowColor = [UIColor colorWithRed:209.0/256.0 green:209.0/256.0 blue:209.0/256.0 alpha:1.0];
        }
        self.popListStyleView.backgroundColor = oddRowColor;
    }else
    {
        if (unoddRowColor == nil) {
            unoddRowColor = [UIColor colorWithRed:238.0/256.0 green:238.0/256.0 blue:238.0/256.0 alpha:1.0];
        }
        self.popListStyleView.backgroundColor = unoddRowColor;
    }
}

- (void) initPopListStyleViewRectWithX:(CGFloat)_x Y:(CGFloat)_y BottomMargin:(CGFloat)_bottomMargin
{
    x = _x;
    y = _y;
    bottomMargin = _bottomMargin;
    
}

- (void) updatePopListStyleView
{
    if (popListStyleView == nil) {
        popListStyleView = [[UIView alloc] init];
        
        /*for (UIView * temp in self.contentView.subviews) {
            [temp removeFromSuperview];
            
            [popListStyleView addSubview:temp];
        }*/
        
        popListStyleView.layer.cornerRadius = 10;
        popListStyleView.clipsToBounds = YES;//按照当前视图裁剪子视图，包括裁剪圆角矩形
        popListStyleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView insertSubview:popListStyleView atIndex:0];
        
        NSLayoutConstraint * popListStyleViewTop = [NSLayoutConstraint constraintWithItem:popListStyleView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:(popListStyleView.superview) attribute:(NSLayoutAttributeTop) multiplier:1.0f constant:y];
        
        NSLayoutConstraint * popListStyleViewLeading = [NSLayoutConstraint constraintWithItem:popListStyleView attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:(popListStyleView.superview) attribute:(NSLayoutAttributeLeading) multiplier:1.0f constant:x];
        
        NSLayoutConstraint * popListStyleViewTrailing = [NSLayoutConstraint constraintWithItem:popListStyleView attribute:(NSLayoutAttributeTrailing) relatedBy:(NSLayoutRelationEqual) toItem:(popListStyleView.superview) attribute:(NSLayoutAttributeTrailing) multiplier:1.0f constant:-x];
        
        NSLayoutConstraint * popListStyleViewBottom = [NSLayoutConstraint constraintWithItem:popListStyleView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:(popListStyleView.superview) attribute:(NSLayoutAttributeBottom) multiplier:1.0f constant:-bottomMargin];
        
        //popListStyleView.superview.backgroundColor = [UIColor redColor];
        
        popListStyleViewTop.active = YES;
        popListStyleViewLeading.active = YES;
        popListStyleViewTrailing.active = YES;
        popListStyleViewBottom.active = YES;


        //NSLog(@"%f,%f", self.contentView.bounds.size.width, popListStyleView.bounds.size.width);
        
    }
}

@end
