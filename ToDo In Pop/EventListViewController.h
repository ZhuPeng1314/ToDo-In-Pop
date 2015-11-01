//
//  EventListViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-20.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class PopupOptionsViewController;
@class PopEventController;

@interface EventListViewController : UITableViewController
{
    NSMutableArray * allEvents;
    
    __weak EKEventStore * eventStore;
    PopEventController * popEventController;
    BOOL isAccessToEventStoreGranted;
    
    UIViewController * subViewController;
    
    PopupOptionsViewController * popupMenuViewController;
}

@property (strong, nonatomic) NSMutableArray * allEvents;

@property (weak, nonatomic) EKEventStore * eventStore;
@property (strong, nonatomic) PopEventController * popEventController;
@property BOOL isAccessToEventStoreGranted;
@property (strong, nonatomic) UIViewController * subViewController;

@property (strong, nonatomic) PopupOptionsViewController * popupMenuViewController;

- (void)reloadEvents;

@end
