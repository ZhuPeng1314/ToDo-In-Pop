//
//  RoleListViewController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-8-31.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "RoleListViewController.h"
#import "AppDelegate.h"
#import "PopRole.h"
#import "EventsForRoleViewController.h"
#import "RoleEditViewController.h"
#import "ZPAlertView.h"
#import "PopupOptionsViewController.h"
#import "PopEventController.h"

#import "PopListStyleCell.h"
#import "DTGlowingLabel.h"
#import "PopNavigationBar.h"

@interface RoleListViewController ()

@end

@implementation RoleListViewController

@synthesize allPopRoles;
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
        
        self.isAccessToEventStoreGranted = YES;
        self.eventStore = appDelegate.eventStore;
        self.allPopRoles = [[NSMutableArray alloc] init];
        self.popEventController = [PopEventController popEventControllerInstanceWithEventStore:eventStore];
        popEventController.isAccessToEventStoreGranted = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:popEventController
                                                 selector:@selector(reloadPopRoles) name:EKEventStoreChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPopRoles) name:@"RoleListReloadPopRoles" object:popEventController];
        
        [popEventController reloadPopRoles];

        
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 0, 5))];//第一个单元格前有个5像素的空隙
        
        UIBarButtonItem * optionsButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:(UIBarButtonItemStyleDone) target:(self) action:@selector(optionsButtonPressed:)];
        self.navigationItem.rightBarButtonItem = optionsButton;

    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:popEventController];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
    [bar setBarTitle:@"角色列表"];
    
    self.subViewController = nil;
}

- (IBAction)optionsButtonPressed:(id)sender
{
    if (popupMenuViewController == nil) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        popupMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"RoleListOptionsSBID"];
    
        popupMenuViewController.superViewController = self;
        popupMenuViewController.selectorList = [[NSMutableArray alloc] init];
        [popupMenuViewController.selectorList addObject:@"addNewRole"];
        [popupMenuViewController.selectorList addObject:@"editRoles"];
    }
    
    CGFloat currentY = self.tableView.bounds.origin.y;
    CGFloat originalY = -(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    popupMenuViewController.view.frame = CGRectMake(130, 5+(currentY - originalY), 185, 87);
    
    if (self.tableView.isEditing) {
        [self editRoles];
    }else
    {
        [popupMenuViewController changeIsDisplayed];
    }
    
}


- (IBAction)addNewRole
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RoleEditViewController * roleEditViewController = [storyboard instantiateViewControllerWithIdentifier:@"RoleEditSBID"];
    
    self.subViewController = roleEditViewController;
    roleEditViewController.rootViewController = self;
    [self.navigationController pushViewController:(roleEditViewController) animated:YES];
}

- (IBAction)editRoles
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

- (void) reloadPopRoles
{
    [allPopRoles removeAllObjects];
    //[popEventController reloadPopRoles];
    [allPopRoles addObjectsFromArray:popEventController.allPopRoles];
    
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allPopRoles count];
}



#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellId = @"roleCellIdentifier";
    PopListStyleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[PopListStyleCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellId];
    }
    
    PopRole * roleForIndexPath = [allPopRoles objectAtIndex:indexPath.row];
    cell.textLabel.text = roleForIndexPath.roleName;

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
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EventsForRoleViewController * eventsForRoleViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventForRoleSBID"];
    
    self.subViewController = eventsForRoleViewController;
    eventsForRoleViewController.popRole = [allPopRoles objectAtIndex:indexPath.row];
    eventsForRoleViewController.rootViewController = self;
    eventsForRoleViewController.popEventController = self.popEventController;
    
    [self.navigationController pushViewController:(eventsForRoleViewController) animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PopRole * roleToDelete = [self.allPopRoles objectAtIndex:indexPath.row];
        NSString * msg = [[NSString alloc] initWithFormat:@"该角色下的所有提醒都将会被删除。确定删除%@吗？",roleToDelete.roleName];
        [ZPAlertView actionSheetWithMessage:msg superViewController:self
                              cancelHandler:^(UIAlertAction *action)
        {
        }
                                  okHandler:^(UIAlertAction *action)
        {
            if ([roleToDelete removeRoleCalendarWithEventStore:eventStore]) {
                [self.allPopRoles removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //由于编辑完后无法恢复到原先的界面布局，故在此延迟1秒刷新一下表格视图
                [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1];
            }else
            {
                [ZPAlertView AlertWithMessage:@"删除角色失败" superViewController:self];
            }

        }];
        
    }
}

#pragma mark - 调整cell尺寸

/*- (void)viewWillLayoutSubviews
{
    NSArray * cells = self.tableView.visibleCells;
    
    for (PopListStyleCell * temp in cells) {
        //CGRect tempRc = temp.contentView.bounds;
        [temp updateContentViewFrame];
        //tempRc = temp.contentView.bounds;
    }
}*/

/*- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{//由于编辑完后无法恢复到原先的界面布局，故在此延迟1秒刷新一下表格视图
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    //[self performSelector:@selector(viewWillLayoutSubviews) withObject:nil afterDelay:1];不会刷新视图
}*/



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
