//
//  EventListViewController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-20.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "EventListViewController.h"

#import "AppDelegate.h"
#import "PopRole.h"
#import "NSDate-ExtractDate.h"
#import "PopEvent.h"
#import "PopListStyleCell.h"
#import "PopEventController.h"
#import "EventEditViewController.h"
#import "PopNavigationBar.h"
#import "PopupOptionsViewController.h"
#import "ZPAlertView.h"

@interface EventListViewController ()

@end

@implementation EventListViewController

@synthesize allEvents;
@synthesize eventStore;
@synthesize popEventController;
@synthesize isAccessToEventStoreGranted;
@synthesize subViewController;
@synthesize popupMenuViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    if (appDelegate.isAccessToEventStoreGranted) {
    
        self.tableView.backgroundColor = [UIColor colorWithRed:238.0/256.0 green:238.0/256.0 blue:238.0/256.0 alpha:1.0];
        
        self.allEvents = [[NSMutableArray alloc] init];
        self.eventStore = appDelegate.eventStore;
        self.isAccessToEventStoreGranted = YES;
        self.popEventController = [PopEventController popEventControllerInstanceWithEventStore:eventStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEvents) name:@"EventListReloadEvents" object:popEventController];
        
        [popEventController reloadPopRoles];
        
        UIBarButtonItem * optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(optionsButtonPressed:)];
        self.navigationItem.rightBarButtonItem = optionsButton;
   
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
    [bar setBarTitle:@"日历列表"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)optionsButtonPressed:(id)sender
{
    if (popupMenuViewController == nil) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        popupMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventListOptionsSBID"];
        
        popupMenuViewController.superViewController = self;
        popupMenuViewController.selectorList = [[NSMutableArray alloc] init];
        [popupMenuViewController.selectorList addObject:@"addNewEvent"];
        [popupMenuViewController.selectorList addObject:@"editEvents"];
    }
    
    CGFloat currentY = self.tableView.bounds.origin.y;
    CGFloat originalY = -(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    popupMenuViewController.view.frame = CGRectMake(130, 5+(currentY - originalY), 185, 87);
    
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
    eventEditViewController.rootViewController = self;
    eventEditViewController.currentPopRole = [[self.popEventController allPopRoles] objectAtIndex:0];
    eventEditViewController.popEventController = self.popEventController;
    
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


- (void)reloadEvents
{
    [allEvents removeAllObjects];
    
    NSDate * tempDate = [[NSDate date] extractDateAfter:-1];
    NSMutableSet * idsOfEvent = [[NSMutableSet alloc] init];
    for (int i=0; i<kDayNumberOfPopYear; i++) {
        NSMutableArray * tempEventsOnOneDay = [popEventController popEventsForRole:nil ForDate:tempDate FromXDay:0 ToYDay:1 WithIdSet:idsOfEvent];
        if ([tempEventsOnOneDay count] > 0) {
            [tempEventsOnOneDay insertObject:tempDate atIndex:0];
            [allEvents addObject:tempEventsOnOneDay];
        }
        tempDate = [tempDate dateAfter:1];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [allEvents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * tempEvents = [allEvents objectAtIndex:section];
    return [tempEvents count] - 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray * tempEvents = [allEvents objectAtIndex:section];
    NSDate * tempDate = [tempEvents objectAtIndex:0];
    NSString * tempDateString = [NSDateFormatter localizedStringFromDate: tempDate dateStyle:(NSDateFormatterShortStyle) timeStyle:(NSDateFormatterNoStyle)];
    return tempDateString;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = @"eventCellIdentifier2";
    PopListStyleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[PopListStyleCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellId];
    }
    
    [cell updatePopListStyleView];
    
    if (indexPath.row % 2) {//根据行号来间隔显示不通的cell颜色
        cell.isOddRow = NO;
    }else{
        cell.isOddRow = YES;
    }
    
    
    PopEvent * cellEvent;
    NSArray * sectionData = [allEvents objectAtIndex:indexPath.section];
    cellEvent = [sectionData objectAtIndex:indexPath.row + 1];
    
    cell.textLabel.text = cellEvent.title;
    
    NSString * tempDateString = [NSDateFormatter localizedStringFromDate: cellEvent.startDate dateStyle:(NSDateFormatterNoStyle) timeStyle:(NSDateFormatterShortStyle)];
    NSString * detailText;
    if (cellEvent.popEventType != kNeverRecurrence) {
        detailText = [[NSString alloc] initWithFormat:@"%@，每%ld%@重复提醒", tempDateString, (long)cellEvent.recurrenceInterval, [cellEvent stringFromRecurrenceTimeUnit]];
    }else
    {
        detailText = [[NSString alloc] initWithFormat:@"%@，永不重复", tempDateString];
    }
    
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopEvent * cellEvent;

    NSArray * section = [self.allEvents objectAtIndex:indexPath.section];
    cellEvent = [section objectAtIndex:indexPath.row+1];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventEditViewController * eventEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventEditSBID"];
    
    self.subViewController = eventEditViewController;
    eventEditViewController.popEventController = self.popEventController;
    if (cellEvent.role == nil) {
        [cellEvent setRoleWithPopEventController:popEventController];
    }
    eventEditViewController.currentPopRole = cellEvent.role;
    eventEditViewController.popEvent = cellEvent;
    
    [self.navigationController pushViewController:(eventEditViewController) animated:YES];

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray * section = [self.allEvents objectAtIndex:indexPath.section];
        PopEvent * eventToDelete = [section objectAtIndex:indexPath.row+1];

        NSString * msg = [[NSString alloc] initWithFormat:@"该提醒以及之后的重复提醒都将会被删除。确定删除%@吗？", eventToDelete.title];
        [ZPAlertView actionSheetWithMessage:msg superViewController:self
                              cancelHandler:^(UIAlertAction *action)
         {
         }
                                  okHandler:^(UIAlertAction *action)
         {
             if ([eventToDelete removeEventWithEventStore:popEventController.eventStore]) {

                 [section removeObjectAtIndex:indexPath.row+1];
                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 
                 if ([section count] == 1) {//改变section数目必须在动画之后，不然会引起错误
                     [self.allEvents removeObjectAtIndex:indexPath.section];
                 }
                 
                 //有可能应用到之后的提醒，所以需要更新列表
                 //[self reloadEventsForRole];
                 [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:(1)];
             }else
             {
                 [ZPAlertView AlertWithMessage:@"删除提醒失败" superViewController:self];
             }
             
         }];
        
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
