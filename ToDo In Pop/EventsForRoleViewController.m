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
#import "PopEventController.h"
#import "NSDate-ExtractDate.h"

#import "PopListStyleCell.h"
#import "PopNavigationBar.h"


@interface EventsForRoleViewController ()

@end

@implementation EventsForRoleViewController

@synthesize popRole;
@synthesize eventsForRoleRecent;
@synthesize eventsForRoleFuture;
@synthesize rootViewController;
@synthesize popEventController;
@synthesize subViewController;
@synthesize popupMenuViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];

    if (popEventController.isAccessToEventStoreGranted) {
        self.tableView.backgroundColor = rootViewController.view.backgroundColor;
        
        self.tableView.delaysContentTouches = NO;
        ///self.tableView.canCancelContentTouches = NO;
        
        self.eventsForRoleRecent = [[NSMutableArray alloc] init];
        self.eventsForRoleFuture = [[NSMutableArray alloc] init];
        [self reloadEventsForRole];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEventsForRole) name:@"EventsForRoleReloadEventsForRole" object:popEventController];
        
        
        UIBarButtonItem * optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(optionsButtonPressed:)];
        self.navigationItem.rightBarButtonItem = optionsButton;
        
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
    [bar setBarTitle:[[NSString alloc] initWithFormat:@"角色:%@", popRole.roleName]];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    eventEditViewController.rootViewController = self.rootViewController;
    eventEditViewController.currentPopRole = self.popRole;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([eventsForRoleRecent count] == 0) {
            return 1;
        }
        return [eventsForRoleRecent count];
    }else
    {
        if ([eventsForRoleFuture count] == 0) {
            return 1;
        }
        return [eventsForRoleFuture count];
    }
}

- (void)reloadEventsForRole
{
   // if ([popEventController hasRole:popRole]) { //防止删除了role的情况下继续刷新该role的数据导致访问到意外的数据
        NSMutableSet * idOfPopEvent = [[NSMutableSet alloc] init];
        
        NSDate * yesterdayDate = [[NSDate date] extractDateAfter:-1];
        eventsForRoleRecent = [popEventController popEventsForRole:popRole ForDate:yesterdayDate FromXDay:0 ToYDay:2 WithIdSet:idOfPopEvent];
        
        eventsForRoleFuture = [popEventController popEventsForRole:popRole ForDate:yesterdayDate FromXDay:2 ToYDay:kDayNumberOfPopYear WithIdSet:idOfPopEvent];
        
        [self.tableView reloadData];
    //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = @"eventCellIdentifier";
    PopListStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
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
    if (indexPath.section == 0) {
        if ([eventsForRoleRecent count] == 0) {
            cell.textLabel.text = @"无";
            cell.detailTextLabel.text = @" ";
            return cell;
        }
        cellEvent = [eventsForRoleRecent objectAtIndex:indexPath.row];
    }else{
        if ([eventsForRoleFuture count] == 0) {
            cell.textLabel.text = @"无";
            cell.detailTextLabel.text = @" ";
            return cell;
        }
        cellEvent = [eventsForRoleFuture objectAtIndex:indexPath.row];
    }
    
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
    
    cell.detailTextLabel.text = detailText;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PopEvent * cellEvent;
    if (indexPath.section == 0) {
        if ([eventsForRoleRecent count] == 0) {
            return;
        }
        cellEvent = [eventsForRoleRecent objectAtIndex:indexPath.row];
    }else{
        if ([eventsForRoleFuture count] == 0) {
            return;
        }
        cellEvent = [eventsForRoleFuture objectAtIndex:indexPath.row];
    }
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventEditViewController * eventEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventEditSBID"];
    
    self.subViewController = eventEditViewController;
    eventEditViewController.rootViewController = self.rootViewController;
    eventEditViewController.currentPopRole = self.popRole;
    eventEditViewController.popEvent = cellEvent;
    eventEditViewController.popEventController = self.popEventController;
    
    [self.navigationController pushViewController:(eventEditViewController) animated:YES];

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([eventsForRoleRecent count] == 0) {
            return NO;
        }
    }else{
        if ([eventsForRoleFuture count] == 0) {
            return NO;
        }
    }
    
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PopEvent * eventToDelete;
        if (indexPath.section == 0) {
            eventToDelete = [eventsForRoleRecent objectAtIndex:indexPath.row];
        }else{
            eventToDelete = [eventsForRoleFuture objectAtIndex:indexPath.row];
        }
        NSString * msg = [[NSString alloc] initWithFormat:@"该提醒以及之后的重复提醒都将会被删除。确定删除%@吗？", eventToDelete.title];
        [ZPAlertView actionSheetWithMessage:msg superViewController:self
                              cancelHandler:^(UIAlertAction *action)
         {
         }
                                  okHandler:^(UIAlertAction *action)
         {
             if ([eventToDelete removeEventWithEventStore:popEventController.eventStore]) {
                 if (indexPath.section == 0) {
                     [eventsForRoleRecent removeObjectAtIndex:indexPath.row];
                     if ([eventsForRoleRecent count] == 0) {
                         [tableView reloadData];
                         return;
                     }
                     //[eventsForRoleRecent removeObjectAtIndex:indexPath.row];
                 }else{
                     [eventsForRoleFuture removeObjectAtIndex:indexPath.row];
                     if ([eventsForRoleFuture count] == 0) {
                         [tableView reloadData];
                         return;
                     }
                 }
                 
                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                 
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"最近的提醒";
    }
    else
    {
        return @"未来的提醒";
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
