//
//  EventsForRoleViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopRole.h"

@class PopupOptionsViewController;

@class RoleListViewController;
@class EventEditViewController;
@class PopEventController;

@interface EventsForRoleViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * eventsForRoleRecent;
    NSMutableArray * eventsForRoleFuture;
    
    
    //下面是上一级必须传入的参数
    PopRole * popRole;
    UIViewController * rootViewController;
    __weak PopEventController * popEventController;
    EventEditViewController * subViewController;
    
    PopupOptionsViewController * popupMenuViewController;
    
}

@property (strong, nonatomic) PopRole * popRole;
@property (strong, nonatomic) NSMutableArray * eventsForRoleRecent;
@property (strong, nonatomic) NSMutableArray * eventsForRoleFuture;
@property (weak, nonatomic) PopEventController * popEventController;

@property (strong, nonatomic) UIViewController * rootViewController;
@property (strong, nonatomic) EventEditViewController * subViewController;
@property (strong, nonatomic) PopupOptionsViewController * popupMenuViewController;

- (void)reloadEventsForRole;
-(IBAction)addNewEvent;

@end
