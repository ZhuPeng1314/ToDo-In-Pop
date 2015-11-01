//
//  EventEditViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-2.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopEvent.h"

@class RoleListViewController;
@class PopEventController;

@interface EventEditViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate>
{
    PopEvent * popEvent;
    __weak UIViewController * rootViewController;
    __weak PopEventController * popEventController;
    PopRole * currentPopRole;
    
    NSInteger recurrenceIntervalMax;
    
    IBOutlet UILabel * title_UI;
    IBOutlet UILabel * roleName_UI;
    IBOutlet UILabel * eventTypeName_UI;
    IBOutlet UITextField * customEventTypeName_UI;
    BOOL isDisplayedCustomEventTypeName_UI;
    IBOutlet UILabel * recurrence_UI;
    IBOutlet UILabel * startDate_UI;
    
    NSMutableArray * cellsDisplayed;
    NSMutableArray * cellsHidden;
    UITableViewCell * displayedPicker;
    NSIndexPath * displayedPickerIndex;
    
    BOOL isFinishButtonDisplayed;
    
}

@property (strong, nonatomic) PopEvent * popEvent;
@property (weak, nonatomic) UIViewController * rootViewController;
@property (weak, nonatomic) PopEventController * popEventController;
@property NSInteger recurrenceIntervalMax;
@property (strong, nonatomic) PopRole * currentPopRole;

@property (strong, nonatomic) UILabel * title_UI;
@property (strong, nonatomic) UILabel * roleName_UI;
@property (strong, nonatomic) UILabel * eventTypeName_UI;
@property (strong, nonatomic) UITextField * customEventTypeName_UI;
@property (strong, nonatomic) UILabel * recurrence_UI;
@property (strong, nonatomic) UILabel * startDate_UI;

@property (strong, nonatomic) NSMutableArray * cellsDisplayed;
@property (strong, nonatomic) NSMutableArray * cellsHidden;
@property (strong, nonatomic) UITableViewCell * displayedPicker;
@property (strong, nonatomic) NSIndexPath * displayedPickerIndex;

@property BOOL isFinishButtonDisplayed;

- (IBAction)updateTitle_UI;
- (IBAction)saveButtonEnable;

@end
