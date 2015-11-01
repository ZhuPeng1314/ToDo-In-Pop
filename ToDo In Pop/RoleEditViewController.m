//
//  RoleEditViewController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-1.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "RoleEditViewController.h"
#import "RoleListViewController.h"
#import "PopRole.h"
#import "ZPAlertView.h"
#import "DTGlowingLabel.h"
#import "PopEventController.h"

#import "PopNavigationBar.h"

@interface RoleEditViewController ()

@end

@implementation RoleEditViewController

@synthesize roleNameTextField;
@synthesize rootViewController;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:(UIBarButtonItemStyleDone) target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PopNavigationBar * bar = (PopNavigationBar *)self.navigationController.navigationBar;
    [bar setBarTitle:@"新建角色"];
}

- (void)saveButtonPressed
{
    NSString * newRoleName = [roleNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([newRoleName length] == 0) {
        roleNameTextField.text = @"";
        [ZPAlertView AlertWithMessage:@"角色名不可以为空" superViewController:self];
    }
    else
    {
        BOOL isNewRole = NO;
        PopRole * newRole = [rootViewController.popEventController addNewRoleWithRoleName:newRoleName isNewRole:&isNewRole];//[[PopRole alloc] initWithRoleName:newRoleName WithEventStore:rootViewController.eventStore isNewRole:&isNewRole];
        if (isNewRole) {
            [rootViewController.allPopRoles addObject:newRole];
            [rootViewController.tableView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [ZPAlertView AlertWithMessage:@"该角色名已存在" superViewController:self];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
