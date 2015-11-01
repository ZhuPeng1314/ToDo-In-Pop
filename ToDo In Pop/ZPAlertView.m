//
//  ZPAlertView.m
//  Pickers
//
//  Created by 鹏 朱 on 15-8-10.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "ZPAlertView.h"

@implementation ZPAlertView


+ (void)AlertWithTitle:(NSString * )title message:(NSString * )msg cancelButtonName:(NSString * )cancelButtonName superViewController:(UIViewController *) viewController
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
        
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:cancelButtonName style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        //必须由alert dismiss自己与上层的强引用，才能消除内存泄漏
    }];
        
    [alertController addAction:cancelButton];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
}

+ (void)AlertWithMessage:(NSString * )msg superViewController:(UIViewController *) viewController
{
    [ZPAlertView AlertWithTitle:@"Tips:" message:msg cancelButtonName:@"OK" superViewController:viewController];
}

+ (void)actionSheetWithTitle:(NSString * )title message:(NSString * )msg cancelButtonName:(NSString * )cancelButtonName OKButtonName:(NSString * )OKButtonName superViewController:(UIViewController *) viewController cancelHandler: (void (^)(UIAlertAction *action))cancelHandler okHandler:(void (^)(UIAlertAction *action))okHandler
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:cancelButtonName style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        cancelHandler(action);
        [alertController dismissViewControllerAnimated:YES completion:nil];
        //必须由alert dismiss自己与上层的强引用，才能消除内存泄漏
    }];
    
    UIAlertAction * OKButton = [UIAlertAction actionWithTitle:OKButtonName style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction *action) {
        okHandler(action);
        [alertController dismissViewControllerAnimated:YES completion:nil];
        //必须由alert dismiss自己与上层的强引用，才能消除内存泄漏
    }];
    
    [alertController addAction:OKButton];
    [alertController addAction:cancelButton];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)actionSheetWithMessage:(NSString * )msg superViewController:(UIViewController *) viewController cancelHandler: (void (^)(UIAlertAction *action))cancelHandler okHandler:(void (^)(UIAlertAction *action))okHandler
{
    [ZPAlertView actionSheetWithTitle:@"Tips:" message:msg cancelButtonName:@"取消" OKButtonName:@"确定" superViewController:viewController cancelHandler:cancelHandler okHandler:okHandler];
}

@end
