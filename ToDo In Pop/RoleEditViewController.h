//
//  RoleEditViewController.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-1.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoleListViewController;

@interface RoleEditViewController : UIViewController
{
    IBOutlet UITextField * roleNameTextField;
    
    __weak RoleListViewController * rootViewController;
}

@property (strong, nonatomic) UITextField * roleNameTextField;
@property (weak, nonatomic) RoleListViewController * rootViewController;

@end
