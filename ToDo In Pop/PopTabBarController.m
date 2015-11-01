//
//  PopTabBarController.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-25.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "PopTabBarController.h"

@interface PopTabBarController ()

@end

@implementation PopTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray * tabBarItems = self.tabBar.items;
    UIImage * roleImage = [[UIImage imageNamed:@"role"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * calendarImage = [[UIImage imageNamed:@"calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem * tempTabBarItem = [tabBarItems objectAtIndex:0];
    tempTabBarItem.image = roleImage;
    
    tempTabBarItem = [tabBarItems objectAtIndex:1];
    tempTabBarItem.image = calendarImage;
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
