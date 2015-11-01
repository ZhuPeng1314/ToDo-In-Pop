//
//  PopNavigationBar.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-24.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopNavigationBar.h"

#import "DTGlowingLabel.h"

@implementation PopNavigationBar

@synthesize navigationBarTitle;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        navigationBarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 72)];
        navigationBarBackground.image = [UIImage imageNamed:@"navigationBarBg2"];
        //[self setBackgroundImage:navigationBarBackground.image forBarMetrics:UIBarMetricsDefault];
        //[self insertSubview:navigationBarBackground atIndex:0];
        
        UIImageView * popLogo = [[UIImageView alloc] initWithFrame:CGRectMake(76.5, 0, 167, 39)];
        popLogo.image = [UIImage imageNamed:@"PopLogo"];
        [self insertSubview:popLogo atIndex:1];
        
        self.navigationBarTitle = [[DTGlowingLabel alloc] initWithFrame:CGRectMake(160, 15, 160, 39)];
        navigationBarTitle.font = [UIFont boldSystemFontOfSize:19];
        navigationBarTitle.textAlignment = NSTextAlignmentCenter;
        [self insertSubview:navigationBarTitle atIndex:2];
        navigationBarTitle.translatesAutoresizingMaskIntoConstraints = NO; //一定要记得加这个，否则会导致约束冲突
        navigationBarTitle.insideColor = [UIColor colorWithRed:9.0/256.0 green:99.0/256.0  blue:154.0/256.0  alpha:1.0];
        navigationBarTitle.outLineColor = navigationBarTitle.insideColor;
        navigationBarTitle.blurColor = [UIColor whiteColor];
        
        NSLayoutConstraint * titleViewCenterX = [NSLayoutConstraint constraintWithItem:navigationBarTitle attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:(navigationBarTitle.superview) attribute:(NSLayoutAttributeCenterX) multiplier:1.0f constant:30];
        NSLayoutConstraint * titleViewTop = [NSLayoutConstraint constraintWithItem:navigationBarTitle attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:(navigationBarTitle.superview) attribute:(NSLayoutAttributeTop) multiplier:1.0f constant:20];
        NSLayoutConstraint * titleViewHeight = [NSLayoutConstraint constraintWithItem:navigationBarTitle attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:(nil) attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0f constant:39];
        NSLayoutConstraint * titleViewWidth = [NSLayoutConstraint constraintWithItem:navigationBarTitle attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:(nil) attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0f constant:200];
        
        titleViewCenterX.active = YES;
        titleViewTop.active = YES;
        titleViewHeight.active = YES;
        titleViewWidth.active = YES;

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.superview insertSubview:navigationBarBackground atIndex:1];
    self.frame = CGRectMake(0, 20, 320, 52);
    [super drawRect:rect];
    
    /*UIView * navigationBar = self.navigationController.navigationBar;
     navigationBar.frame = CGRectMake(0, 20, 320, 52);
     
     UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, -20, 320, 72) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
     CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
     maskLayer.frame = navigationBar.bounds;
     maskLayer.path = maskPath.CGPath;
     navigationBar.layer.mask = maskLayer;*/
    //mask没有设置时，navigationBar的背景图片会延伸到顶部状态栏，如果设置了mask则不会延伸到状态栏
}

- (void)setBarTitle:(NSString *)_title
{
    navigationBarTitle.text = _title;
}


@end
