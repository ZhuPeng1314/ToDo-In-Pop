//
//  EventsForRoleViewController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "EventsForRoleViewController.h"
#import "PopEvent.h"
#import "RoleListViewController.h"
#import "EventEditViewController.h"
#import "PopupOptionsViewController.h"
#import "ZPAlertView.h"

#import "PopListStyleCell.h"
#import "DTGlowingLabel.h"


@interface EventsForRoleViewController ()

@end

@implementation EventsForRoleViewController

@synthesize popRole;
@synthesize eventsForRole;
@synthesize rootViewController;
@synthesize subViewController;
@synthesize popupMenuViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    
    if (rootViewController.isAccessToEventStoreGranted) {
        self.eventsForRole = [[NSMutableArray alloc] init];
        [self reloadEventsForRole];
        
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 0, 5))];//第一个单元格前有个5像素的空隙
        
        
        UIBarButtonItem * optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(optionsButtonPressed:)];
        self.navigationItem.rightBarButtonItem = optionsButton;
        
        /*UIBarButtonItem * addNewEventButton = [[UIBarButtonItem alloc] initWithTitle:@"新提醒" style:(UIBarButtonItemStyleDone) target:self action:@selector(addNewEvent)];
        self.navigationItem.rightBarButtonItem = addNewEventButton;*/
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.rootViewController.navigationBarTitle.text = [[NSString alloc] initWithFormat:@"角色:%@", popRole.roleName];
    
}

- (IBAction)optionsButtonPressed:(id)sender
{
    if (popupMenuViewController == nil) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        popupMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventListOptionsSBID"];
        popupMenuViewController.view.frame = CGRectMake(130, 5, 185, 87);
        
        popupMenuViewController.superViewController = self;
        popupMenuViewController.selectorList = [[NSMutableArray alloc] init];
        [popupMenuViewController.selectorList addObject:@"addNewEvent"];
        [popupMenuViewController.selectorList addObject:@"editEvents"];
    }
    
    
    if (self.tableView.isEditing) {
        [self editEvents];
    }else
    {
        [popupMenuViewController changeIsDisplayed];
    }
}

-(IBAction)addNewEvent
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventEditViewController * eventEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventEditSBID"];
    
    self.subViewController = eventEditViewController;
    eventEditViewController.rootViewController = self.rootViewController;
    eventEditViewController.currentPopRole = self.popRole;
    
    [self.navigationController pushViewController:(eventEditViewController) animated:YES];
}

-(IBAction)editEvents
{
    [self.tableView setEditing:!(self.tableView.isEditing) animated:YES];
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem.title = @"完成";
    }
    else
    {
        self.navigationItem.rightBarButtonItem.title = @"选项";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [eventsForRole count];
}

- (void)reloadEventsForRole
{
    [eventsForRole removeAllObjects];
    NSArray * events = [self eventsFromYesterdayToXDay:kDayNumberOfPopYear FromRole:popRole];
    for (EKEvent * tempEvent in events) {
        PopEvent * tempPopEvent = [[PopEvent alloc] initWithEvent:tempEvent WithPopRole:popRole];
        [eventsForRole addObject:tempPopEvent];
    }

}

- (NSArray *)eventsFromYesterdayToXDay: (NSInteger) dayNumber FromRole:(PopRole *) _popRole
{
    NSCalendar *nsCalendar = [NSCalendar currentCalendar];
    EKEventStore * eventStore = self.rootViewController.eventStore;
    
    // 创建起始和结束日期
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;
    NSDate * oneDayAgo = [nsCalendar dateByAddingComponents:oneDayAgoComponents toDate:[NSDate date] options:0];
    
    
    NSDateComponents * xDayFromNowComponents = [[NSDateComponents alloc] init];
    xDayFromNowComponents.day = dayNumber;
    NSDate * xDayFromNow = [nsCalendar dateByAddingComponents:xDayFromNowComponents toDate:[NSDate date] options:0];
    
    // 用事件库的实例方法创建谓词
    NSPredicate * predicate = [eventStore predicateForEventsWithStartDate:oneDayAgo endDate:xDayFromNow calendars:@[_popRole.roleCalendar]];
    
    // 获取所有匹配该谓词的事件
    NSArray * events = [eventStore eventsMatchingPredicate:predicate];
    return  events;
    
    //return [self eventsFromXDay:-1 ToYDay:dayNumber FromRole:_popRole];
}

/*- (NSArray *)eventsFromXDay:(NSInteger) xDayNumber ToYDay: (NSInteger) yDayNumber FromRole:(PopRole *) _popRole
{
    NSCalendar *nsCalendar = [NSCalendar currentCalendar];
    EKEventStore * eventStore = self.rootViewController.eventStore;
    
    // 创建起始和结束日期
    NSDateComponents *xDayComponents = [[NSDateComponents alloc] init];
    xDayComponents.day = xDayNumber;
    NSDate * xDay = [nsCalendar dateByAddingComponents:xDayComponents toDate:[NSDate date] options:0];
    
    
    NSDateComponents * yDayFromNowComponents = [[NSDateComponents alloc] init];
    yDayFromNowComponents.day = yDayNumber;
    NSDate * yDayFromNow = [nsCalendar dateByAddingComponents:yDayFromNowComponents toDate:[NSDate date] options:0];
    
    // 用事件库的实例方法创建谓词
    NSPredicate * predicate = [eventStore predicateForEventsWithStartDate:xDay endDate:yDayFromNow calendars:@[_popRole.roleCalendar]];
    
    // 获取所有匹配该谓词的事件
    NSArray * events = [eventStore eventsMatchingPredicate:predicate];
    return  events;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = @"eventCellIdentifier";
    PopListStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[PopListStyleCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellId];
    }
    
    PopEvent * cellEvent = [eventsForRole objectAtIndex:indexPath.row];
    
    NSString * eventTitle = cellEvent.title;
    NSArray * separated = [eventTitle componentsSeparatedByString:@": "];
    if ([separated count] > 0) {
        cell.textLabel.text = [separated objectAtIndex:[separated count]-1];
    }
    
    NSString * tempDateString = [NSDateFormatter localizedStringFromDate: cellEvent.startDate dateStyle:(NSDateFormatterShortStyle) timeStyle:(NSDateFormatterShortStyle)];
    NSString * detailText;
    if (cellEvent.popEventType != kNeverRecurrence) {
        detailText = [[NSString alloc] initWithFormat:@"%@，每%ld%@重复提醒", tempDateString, (long)cellEvent.recurrenceInterval, [cellEvent stringFromRecurrenceTimeUnit]];
    }else
    {
        detailText = [[NSString alloc] initWithFormat:@"%@，永不重复", tempDateString];
    }
    
    //NSLog(@"%@,%@",cellEvent.title, cellEvent.ekEvent.eventIdentifier);
    //NSLog(@"%@, alarms count: %lu",cellEvent.title, (unsigned long)[cellEvent.ekEvent.alarms count]);
    
    cell.detailTextLabel.text = detailText;
    
    [cell updatePopListStyleView];
    
    if (indexPath.row % 2) {//根据行号来间隔显示不通的cell颜色
        cell.isOddRow = NO;
    }else{
        cell.isOddRow = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (popupMenuViewController.isDisplayed) {
        [popupMenuViewController changeIsDisplayed];
    }
    
    PopEvent * cellEvent = [eventsForRole objectAtIndex:indexPath.row];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventEditViewController * eventEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventEditSBID"];
    
    self.subViewController = eventEditViewController;
    eventEditViewController.rootViewController = self.rootViewController;
    eventEditViewController.currentPopRole = self.popRole;
    eventEditViewController.popEvent = cellEvent;
    
    [self.navigationController pushViewController:(eventEditViewController) animated:YES];

}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PopEvent * eventToDelete = [eventsForRole objectAtIndex:indexPath.row];
        NSString * msg = [[NSString alloc] initWithFormat:@"该提醒以及之后的重复提醒都将会被删除。确定删除%@吗？", eventToDelete.title];
        [ZPAlertView actionSheetWithMessage:msg superViewController:self
                              cancelHandler:^(UIAlertAction *action)
         {
         }
                                  okHandler:^(UIAlertAction *action)
         {
             if ([eventToDelete removeEventWithEventStore:rootViewController.eventStore]) {
                 [self.eventsForRole removeObjectAtIndex:indexPath.row];
                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 
                 //有可能应用到之后的提醒，所以需要更新列表
                 [self reloadEventsForRole];
                 [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:(1)];
             }else
             {
                 [ZPAlertView AlertWithMessage:@"删除提醒失败" superViewController:self];
             }
             
         }];
        
    }
}


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
