//
//  EventEditViewController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-2.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "EventEditViewController.h"
#import "PopEvent.h"
#import "RoleListViewController.h"
#import "PopRole.h"
#import "ZPAlertView.h"
#import "EventsForRoleViewController.h"
#import "PopEventController.h"
#import "EventListViewController.h"

#import "PopListStyleCell.h"
#import "PopNavigationBar.h"

#define kRoleNamePickerTag 1
#define kEventTypePickerTag 2
#define kRecurrencePickerTag 3

#define kNeverRecurrenceIndex 4

@interface EventEditViewController ()

@end

@implementation EventEditViewController

@synthesize popEvent;
@synthesize rootViewController;
@synthesize popEventController;
@synthesize recurrenceIntervalMax;
@synthesize currentPopRole;

@synthesize title_UI;
@synthesize roleName_UI;
@synthesize eventTypeName_UI;
@synthesize customEventTypeName_UI;
@synthesize recurrence_UI;
@synthesize startDate_UI;

@synthesize cellsDisplayed;
@synthesize cellsHidden;
@synthesize displayedPicker;
@synthesize displayedPickerIndex;

@synthesize isFinishButtonDisplayed;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    recurrenceIntervalMax = 500;
    isDisplayedCustomEventTypeName_UI = NO;
    self.tableView.rowHeight = 44.0f;
    
    if (popEvent == nil) {
        //创建新的事件
        PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
        [bar setBarTitle:@"新提醒"];
        
        self.popEvent = [[PopEvent alloc] init];
        self.popEvent.role = self.currentPopRole;
        self.popEvent.ekCalendar = self.currentPopRole.roleCalendar;
        self.popEvent.popEventType = kBirthDay;
        self.popEvent.startDate = [NSDate date];
        self.popEvent.recurrenceTimeUnit = kPopYear;
        self.popEvent.recurrenceInterval = 1;
        self.popEvent.customEventTypeName = @"未命名";
        
        [self saveButtonEnable];
        
    }else
    {
        //编辑已有事件
        PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
        [bar setBarTitle:@"编辑已有提醒"];
    }
    
    
    /*UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(testButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;*/
    
    [self updateEventInfo_UI];
    
    if (popEvent.ekEvent == nil) {
        isFinishButtonDisplayed = NO;
    }else if (popEvent.popEventType == kBirthDay)
    {
        isFinishButtonDisplayed = NO;
    }else if ([popEvent.startDate compare:[NSDate date]] == 1)
    {
        isFinishButtonDisplayed = NO;
    }else
    {
        isFinishButtonDisplayed = YES;
    }
    
    
    self.cellsDisplayed = [[NSMutableArray alloc] init];
    self.cellsHidden = [[NSMutableArray alloc] init];
    self.displayedPickerIndex = nil;
    for (int i = 0; i<4; i++) {
        [cellsDisplayed addObject:[super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]]];
    }
    for (int i=4; i<9; i++) {
        [cellsHidden addObject:[super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]]];
    }
}

- (IBAction)saveButtonEnable
{
    if (self.navigationItem.rightBarButtonItem == nil)
    {
        UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
}

/*- (IBAction)testButtonPressed:(id)sender
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    static EventsForRoleOptionsViewController * popupMenuViewController;
    popupMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"PopupMenuSBID"];
    popupMenuViewController.view.frame = CGRectMake(130, 5, 185, 87);
    
    [self.view addSubview:popupMenuViewController.view];
    //[self presentViewController:popupMenuViewController animated:YES completion:nil];
}*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (popEvent.ekEvent != nil) {
        [self.popEvent removeEventWithEventStore:popEventController.eventStore];
    }
    
    [self.popEvent eventDataWriteToEkEventWithEventStore:popEventController.eventStore];
    NSError * error;
    BOOL success = [popEventController.eventStore saveEvent:popEvent.ekEvent span:(EKSpanFutureEvents) commit:YES error:&error];
    
    if (success) {
        if ([rootViewController isMemberOfClass:[RoleListViewController class]]) {
            RoleListViewController * root = (RoleListViewController * )rootViewController;
            EventsForRoleViewController * eventListViewController = (EventsForRoleViewController * )root.subViewController;
            UITableView * eventListView = (UITableView * )eventListViewController.view;
            [eventListViewController reloadEventsForRole];
            [eventListView reloadData];
        }else if ([rootViewController isMemberOfClass:[EventListViewController class]])
        {
            EventListViewController * root = (EventListViewController * )rootViewController;
            UITableView * eventListView = (UITableView * )root.view;
            [root reloadEvents];
            [eventListView reloadData];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [ZPAlertView AlertWithMessage:@"保存提醒失败，请重试。" superViewController:self];
    }
}

- (NSString *)generateTitleFromEventType
{
    NSString * eventTypeString = [self.popEvent stringFromEventType];
    if (popEvent.popEventType == kCustom) {
        NSString * newCustomEventTypeName = [self.customEventTypeName_UI.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        popEvent.customEventTypeName = newCustomEventTypeName;
        if (popEvent.customEventTypeName == nil || [popEvent.customEventTypeName length] == 0)
        {
            popEvent.customEventTypeName = @"未命名";
        }
        eventTypeString = [[NSString alloc] initWithFormat:@"%@: %@", eventTypeString, popEvent.customEventTypeName];
    }
    return [[NSString alloc] initWithFormat:@"%@: %@", self.popEvent.role.roleName, eventTypeString];
}

- (IBAction)updateTitle_UI
{
    self.popEvent.title = [self generateTitleFromEventType];
    self.title_UI.text = self.popEvent.title;
}

- (void)updateRoleName_UI
{
    self.roleName_UI.text = self.popEvent.role.roleName;
}

- (void)updateEventTypeName_UI
{
    self.eventTypeName_UI.text = [self.popEvent stringFromEventType];
}

- (void)updateRecurrence_UI
{
    if (self.popEvent.recurrenceTimeUnit == kNeverRecurrence) {
        self.recurrence_UI.text = [self.popEvent stringFromRecurrenceTimeUnit];
    }
    else
    {
        self.recurrence_UI.text = [[NSString alloc] initWithFormat:@"每 %ld %@", self.popEvent.recurrenceInterval, [self.popEvent stringFromRecurrenceTimeUnit]];
    }
}

- (void)updateStartDate_UI
{
    self.startDate_UI.text = [NSDateFormatter localizedStringFromDate: self.popEvent.startDate dateStyle:(NSDateFormatterShortStyle) timeStyle:(NSDateFormatterShortStyle)];
}

- (void)updateEventInfo_UI
{
    self.customEventTypeName_UI.text = self.popEvent.customEventTypeName;
    
    [self updateTitle_UI];
    [self updateRoleName_UI];
    [self updateEventTypeName_UI];
    
    [self updateRecurrence_UI];
    [self updateStartDate_UI];
}

- (void)initPicker
{
    UIView * viewFromTag = [displayedPicker.contentView viewWithTag:(displayedPicker.tag-10)];
    if (displayedPicker.tag-10 < 4) {
        UIPickerView * pickerView = (UIPickerView * )viewFromTag;
        switch (pickerView.tag) {
            case kRoleNamePickerTag:
            {
                NSArray * roles = [self.popEventController allPopRoles];
                PopRole * tempRole;
                for (int i=0; i<[roles count]; i++) {
                    tempRole = [roles objectAtIndex:i];
                    if (tempRole == self.popEvent.role) {
                        [pickerView selectRow:i inComponent:0 animated:NO];
                        break;
                    }
                }
                break;
            }
            case kEventTypePickerTag:
                [pickerView selectRow:popEvent.popEventType inComponent:0 animated:NO];
                break;
            case kRecurrencePickerTag:
                [pickerView selectRow:popEvent.recurrenceTimeUnit inComponent:1 animated:NO];
                if (popEvent.recurrenceTimeUnit != kNeverRecurrence) {
                    [pickerView selectRow:popEvent.recurrenceInterval-1 inComponent:0 animated:NO];
                }
                break;
            default:
                break;
        }
    }
    else
    {
        if (popEvent != nil) {//当编辑已有提醒时，需要初始化时间picker
            UIDatePicker * datePickerView = (UIDatePicker * )viewFromTag;
            [datePickerView setDate:popEvent.startDate animated:NO];
        }
    }
}

- (IBAction)PickerValueChanged:(id)sender
{
    [self saveButtonEnable];
    
    UIView * viewFromSender = sender;
    if (viewFromSender.tag < 4) {
        UIPickerView * pickerView = (UIPickerView * )viewFromSender;
        NSInteger index0 = [pickerView selectedRowInComponent:0];
        
        switch (pickerView.tag) {
            case kRoleNamePickerTag:
            {
                NSArray * roles = [self.popEventController allPopRoles];
                PopRole * tempRole = [roles objectAtIndex:index0];
                popEvent.role = tempRole;
                popEvent.ekCalendar = tempRole.roleCalendar;
                [self updateRoleName_UI];
                [self updateTitle_UI];
                break;
            }
            case kEventTypePickerTag:
            {
                popEvent.popEventType = index0;
                [self updateEventTypeName_UI];
                [self updateTitle_UI];
                
                switch (index0)
                {
                    case kBirthDay:
                    {
                        popEvent.recurrenceTimeUnit = kPopYear;
                        popEvent.recurrenceInterval = 1;
                        break;
                    }
                    case kMagicCube:
                    case kSecretBook:
                    {
                        popEvent.recurrenceTimeUnit = kDay;
                        popEvent.recurrenceInterval = 1;
                        break;
                    }
                    case kGrinch:
                    {
                        popEvent.recurrenceTimeUnit = kWeek;
                        popEvent.recurrenceInterval = 2;
                        break;
                    }
                    case kGrandparentsPicture:
                    {
                        popEvent.recurrenceTimeUnit = kPopYear;
                        popEvent.recurrenceInterval = 1;
                        break;
                    }
                        
                    default:
                        break;
                }
                [self updateRecurrence_UI];
                
                break;
            }
            case kRecurrencePickerTag:
            {
                popEvent.recurrenceTimeUnit = [pickerView selectedRowInComponent:1];
                if (popEvent.recurrenceTimeUnit != kNeverRecurrence) {
                    popEvent.recurrenceInterval = index0+1;
                }
                [self updateRecurrence_UI];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        UIDatePicker * datePickerView = (UIDatePicker * )viewFromSender;
        popEvent.startDate = datePickerView.date;
        [self updateStartDate_UI];
    }
}

#pragma mark - Picker view data source and delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == kRoleNamePickerTag || pickerView.tag == kEventTypePickerTag)
    {
        return 1;
    }
    else if (pickerView.tag == kRecurrencePickerTag)
    {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == kRoleNamePickerTag)
    {
        return [[popEventController allPopRoles] count];
    }
    else if (pickerView.tag == kEventTypePickerTag)
    {
        return [[popEvent allEventTypeNames] count];
        
    }
    else if (pickerView.tag == kRecurrencePickerTag)
    {
        if (component == 1) {
            return [[popEvent allRecurrenceTimeUnitNames] count];
        }else
        {
            return recurrenceIntervalMax;
        }
    }
    return 0;
}

/*-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == kRoleNamePickerTag) {
        PopRole * tempRole = [[popEventController allPopRoles] objectAtIndex:row];
        return tempRole.roleName;
    }
    else if (pickerView.tag == kEventTypePickerTag)
    {
        return [popEvent.allEventTypeNames objectAtIndex:row];
    }
    else if (pickerView.tag == kRecurrencePickerTag)
    {
        if (component == 1) {
            return [[popEvent allRecurrenceTimeUnitNames] objectAtIndex:row];
        }else
        {
            return [[NSString alloc] initWithFormat:@"每%ld", row+1];
        }
    }
    return nil;
}*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString * resultString;
    
    if (pickerView.tag == kRoleNamePickerTag) {
        PopRole * tempRole = [[popEventController allPopRoles] objectAtIndex:row];
        resultString = tempRole.roleName;
    }
    else if (pickerView.tag == kEventTypePickerTag)
    {
        resultString = [popEvent.allEventTypeNames objectAtIndex:row];
    }
    else if (pickerView.tag == kRecurrencePickerTag)
    {
        if (component == 1) {
            resultString = [[popEvent allRecurrenceTimeUnitNames] objectAtIndex:row];
        }else
        {
            resultString = [[NSString alloc] initWithFormat:@"每%ld", row+1];
        }
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.text = resultString;
    label.textColor = [UIColor colorWithRed:9.0/256.0 green:99.0/256.0  blue:154.0/256.0  alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:25];
    
    return label;
}

- (void) changeCustomEventTypeNameUIDisplayed
{
    if (isDisplayedCustomEventTypeName_UI == NO) {
        isDisplayedCustomEventTypeName_UI = YES;
        UITableViewCell * customCell = [self.cellsHidden objectAtIndex:0];
        UITableViewCell * upCell = [self.cellsDisplayed objectAtIndex:2];
        NSIndexPath * displayedCumstomCellIndex;
        if (upCell.tag > 10) {
            [cellsDisplayed insertObject:customCell atIndex:3];
            displayedCumstomCellIndex = [NSIndexPath indexPathForRow:3 inSection:1];
        }else
        {
            [cellsDisplayed insertObject:customCell atIndex:2];
            displayedCumstomCellIndex = [NSIndexPath indexPathForRow:2 inSection:1];
        }
        //[self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[displayedCumstomCellIndex] withRowAnimation:(UITableViewRowAnimationLeft)];
        customEventTypeName_UI.text = self.popEvent.customEventTypeName;
        //[self.tableView endUpdates];
        
        //[self.tableView reloadData];//插入行和删除行的动画会造成cell的轻微移动，遮挡某些分割线，用reloadData方法来刷新列表重新调整UI
    }
    else{
        isDisplayedCustomEventTypeName_UI = NO;
        UITableViewCell * upCell = [self.cellsDisplayed objectAtIndex:2];
        NSIndexPath * displayedCumstomCellIndex;
        if (upCell.tag > 10) {
            [cellsDisplayed removeObjectAtIndex:3];
            displayedCumstomCellIndex = [NSIndexPath indexPathForRow:3 inSection:1];
        }else
        {
            [cellsDisplayed removeObjectAtIndex:2];
            displayedCumstomCellIndex = [NSIndexPath indexPathForRow:2 inSection:1];
        }
        
        //[self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[displayedCumstomCellIndex] withRowAnimation:UITableViewRowAnimationLeft];
        //[self.tableView endUpdates];
        
        //[self.tableView reloadData];

    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == kRecurrencePickerTag)
    {
        if (component == 1) {
            if (row == kNeverRecurrenceIndex) {
                recurrenceIntervalMax = 0;
                [pickerView reloadComponent:0];
            }else
            {
                recurrenceIntervalMax = 500;
                [pickerView reloadComponent:0];
            }
        }
    }else if (pickerView.tag == kEventTypePickerTag)
    {
        if (row == kCustom && isDisplayedCustomEventTypeName_UI == NO)
        {//选中 “自定义”
            /*isDisplayedCustomEventTypeName_UI = YES;
            UITableViewCell * customCell = [self.cellsHidden objectAtIndex:0];
            [cellsDisplayed insertObject:customCell atIndex:3];
            NSIndexPath * displayedCumstomCellIndex = [NSIndexPath indexPathForRow:3 inSection:1];
            [self.tableView insertRowsAtIndexPaths:@[displayedCumstomCellIndex] withRowAnimation:(UITableViewRowAnimationLeft)];
            customEventTypeName_UI.text = self.popEvent.customEventTypeName;
            [self.tableView reloadData];//插入行和删除行的动画会造成cell的轻微移动，遮挡某些分割线，用reloadData方法来刷新列表重新调整UI*/
            [self changeCustomEventTypeNameUIDisplayed];
        }else if (row != kCustom && isDisplayedCustomEventTypeName_UI == YES)
        {
            /*isDisplayedCustomEventTypeName_UI = NO;
            [cellsDisplayed removeObjectAtIndex:3];
            NSIndexPath * displayedCumstomCellIndex = [NSIndexPath indexPathForRow:3 inSection:1];
            [self.tableView deleteRowsAtIndexPaths:@[displayedCumstomCellIndex] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView reloadData];*/
            [self changeCustomEventTypeNameUIDisplayed];
        }
    }
    [self PickerValueChanged:pickerView];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (displayedPickerIndex != nil && indexPath.section == 1 && indexPath.row == displayedPickerIndex.row) {
        return 130.0f;
    }else if (indexPath.section == 2)
    {
        return 65.f;
    }
    return 50.0f;
}

- (NSInteger) pickerRowFromTag: (NSInteger)tag
{
    if (isDisplayedCustomEventTypeName_UI == NO) {
        return tag;
    }else
    {
        if (tag >= 3) {
            return tag+1;
        }else{
            return tag;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        UITableViewCell * currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.selected = NO;//使这个单元格不会一直高亮显示
        
        if (currentCell.tag > 9) {//如果点击的为自定义类型名或者Picker所在的行
            return;
        }
        UITableViewCell * needToDisplayPicker = [cellsHidden objectAtIndex:currentCell.tag];
        if (displayedPicker != nil) {
            if (displayedPicker != needToDisplayPicker) {//需要显示的picker和已显示的picker不同时，隐藏已经显示的，而显示新的picker
                /*[cellsDisplayed removeObject:displayedPicker];
                [tableView deleteRowsAtIndexPaths:@[displayedPickerIndex] withRowAnimation:(UITableViewRowAnimationFade)];
                
                displayedPicker = needToDisplayPicker;
                displayedPickerIndex = [NSIndexPath indexPathForRow:[self pickerRowFromTag:currentCell.tag] inSection:1];
                [cellsDisplayed insertObject:needToDisplayPicker atIndex:displayedPickerIndex.row];
                [tableView insertRowsAtIndexPaths:@[displayedPickerIndex] withRowAnimation:(UITableViewRowAnimationFade)];
                */
                
                [cellsDisplayed removeObject:displayedPicker];//数据层删除旧的已显示的Picker
                NSIndexPath * newDisplayedPickerIndex = [NSIndexPath indexPathForRow:[self pickerRowFromTag:currentCell.tag] inSection:1];
                //新的将要显示的picker所在的位置
                displayedPicker = needToDisplayPicker;//新的Picker保存在全局指针中
                [cellsDisplayed insertObject:needToDisplayPicker atIndex:newDisplayedPickerIndex.row];//数据层插入新的picker
                
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[displayedPickerIndex] withRowAnimation:(UITableViewRowAnimationFade)];//显示层删除旧的picker
                displayedPickerIndex = newDisplayedPickerIndex;//新的Picker的位置保存在全局指针中
                [tableView insertRowsAtIndexPaths:@[displayedPickerIndex] withRowAnimation:(UITableViewRowAnimationFade)];//显示层插入新的picker
                [tableView endUpdates];
                
                [self initPicker];
            }else
            {//需要显示的picker和已显示的picker相同时，只隐藏该picker
                [cellsDisplayed removeObject:displayedPicker];
                displayedPicker = nil;
                displayedPickerIndex = nil;
                [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self pickerRowFromTag:currentCell.tag] inSection:1]] withRowAnimation:(UITableViewRowAnimationFade)];
            }
        }else
        {//没有已经显示的picker
            displayedPicker = needToDisplayPicker;
            displayedPickerIndex = [NSIndexPath indexPathForRow:[self pickerRowFromTag:currentCell.tag] inSection:1];
            [cellsDisplayed insertObject:needToDisplayPicker atIndex:displayedPickerIndex.row];
            [tableView insertRowsAtIndexPaths:@[displayedPickerIndex] withRowAnimation:(UITableViewRowAnimationFade)];
            [self initPicker];
        }
        if (popEvent.popEventType == kCustom && currentCell.tag == 2 && isDisplayedCustomEventTypeName_UI == NO) {
            [self changeCustomEventTypeNameUIDisplayed];
        }else if (customEventTypeName_UI.isFirstResponder && currentCell.tag != 10)
        {
            [customEventTypeName_UI resignFirstResponder];
            [self updateTitle_UI];
        }
        
    }else if (indexPath.section == 2)
    {
        NSDateComponents * newStartDateComponent = [[NSDateComponents alloc] init];
        newStartDateComponent.minute = -1;
        NSDate * newStartDate = [[NSCalendar currentCalendar] dateByAddingComponents:newStartDateComponent toDate:[NSDate date] options:0];
        popEvent.startDate = newStartDate;
        [self updateStartDate_UI];
        [self saveButtonPressed:nil];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isFinishButtonDisplayed) {
        return 3;
    }
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        //NSLog(@"%lu",(unsigned long)[cellsDisplayed count]);
        return [cellsDisplayed count];
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopListStyleCell * temp;
    if (indexPath.section == 1) {
        temp = [cellsDisplayed objectAtIndex:indexPath.row];
        [temp updatePopListStyleView];
        if (temp.tag > 10)
        {
            temp.isOddRow = NO;
        }else{
            temp.isOddRow = YES;
        }
        return temp;
    }else if (indexPath.section == 2)
    {
        temp = (PopListStyleCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        //temp.cellHeight = 65;
        [temp updatePopListStyleView];
        return temp;
    }
    
    temp = (PopListStyleCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [temp updatePopListStyleView];
    temp.isOddRow = YES;
    
    return temp;
}


#pragma mark - 调整cell尺寸

/*- (void)viewWillLayoutSubviews
{
    NSArray * cells = self.tableView.visibleCells;
    
    for (PopListStyleCell * temp in cells) {
        [temp updateContentViewFrame];
    }
}*/

/*- (void)viewWillLayoutSubviews
{
    NSArray * cells = self.tableView.visibleCells;
    
    for (UITableViewCell * temp in cells) {
        if (temp.tag < 11) {
            temp.bounds = CGRectMake(5, 0, self.tableView.bounds.size.width - 10, 45);
        }else if (temp.tag < 20)
        {
            temp.bounds = CGRectMake(5, 0, self.tableView.bounds.size.width - 10, 144);
        }else
        {
            temp.bounds = CGRectMake(5, 0, self.tableView.bounds.size.width - 10, 60);
        }
    }
}*/

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
 
    
    return cell;
}*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
