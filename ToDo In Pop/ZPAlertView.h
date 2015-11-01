//
//  ZPAlertView.h
//  Pickers
//
//  Created by 鹏 朱 on 15-8-10.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZPAlertView : NSObject
{
}

+ (void)AlertWithTitle:(NSString * )title message:(NSString * )msg cancelButtonName:(NSString * )cancelButtonName superViewController:(UIViewController *) viewController;

+ (void)AlertWithMessage:(NSString * )msg superViewController:(UIViewController *) viewController;

+ (void)actionSheetWithTitle:(NSString * )title message:(NSString * )msg cancelButtonName:(NSString * )cancelButtonName OKButtonName:(NSString * )OKButtonName superViewController:(UIViewController *) viewController cancelHandler: (void (^)(UIAlertAction *action))cancelHandler okHandler:(void (^)(UIAlertAction *action))okHandler;

+ (void)actionSheetWithMessage:(NSString * )msg superViewController:(UIViewController *) viewController cancelHandler: (void (^)(UIAlertAction *action))cancelHandler okHandler:(void (^)(UIAlertAction *action))okHandler;


@end
