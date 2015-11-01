//
//  PopupOptionsViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-9.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupOptionsViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
{
    UIViewController * superViewController;
    NSMutableArray * selectorList;
    BOOL isDisplayed;
}

@property (strong, nonatomic) UIViewController * superViewController;
@property (strong, nonatomic) NSMutableArray * selectorList;
@property BOOL isDisplayed;

- (void)changeIsDisplayed;

@end
