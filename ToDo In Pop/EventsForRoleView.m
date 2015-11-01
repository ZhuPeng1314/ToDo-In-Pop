//
//  EventsForRoleView.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-17.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "EventsForRoleView.h"

#import "EventsForRoleViewController.h"
#import "PopupOptionsViewController.h"

@implementation EventsForRoleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.delaysContentTouches = NO;
        ///self.canCancelContentTouches = NO;
    }
    return self;
}

- (void)touchOutOfPopupMenuView:(NSSet *)touches
{
    EventsForRoleViewController * viewController = (EventsForRoleViewController *)self.nextResponder;
    
    if (viewController.popupMenuViewController.isDisplayed) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        CGRect popupMenuframe = viewController.popupMenuViewController.view.frame;
        if (touchLocation.x < popupMenuframe.origin.x || touchLocation.x > popupMenuframe.origin.x + popupMenuframe.size.width || touchLocation.y < popupMenuframe.origin.y || touchLocation.y > popupMenuframe.origin.y + popupMenuframe.size.height)
        {
            //在popupMenu的范围外，需要隐藏
            [viewController.popupMenuViewController changeIsDisplayed];
        }
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{//手指在最后一个cell之后滑动或者点击会触发这个方法，而不触发touchesShouldBegin
    [self touchOutOfPopupMenuView:touches];
    
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{//手指在cell上或者cells之间滑动或者点击会首先触发这个方法
    
    [self touchOutOfPopupMenuView:touches];
    
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

@end
