//
//  RoleListViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class PopupOptionsViewController;
@class DTGlowingLabel;
@class PopEventController;

@interface RoleListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * allPopRoles;
    
    __weak EKEventStore * eventStore;
    PopEventController * popEventController;
    BOOL isAccessToEventStoreGranted;
    
    UIViewController * subViewController;
    
    PopupOptionsViewController * popupMenuViewController;
}

@property (strong, nonatomic) NSMutableArray * allPopRoles;
@property (weak, nonatomic) EKEventStore * eventStore;
@property (strong, nonatomic) PopEventController * popEventController;
@property BOOL isAccessToEventStoreGranted;
@property (strong, nonatomic) UIViewController * subViewController;

@property (strong, nonatomic) PopupOptionsViewController * popupMenuViewController;

@end
