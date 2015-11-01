//
//  PopNavigationBar.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-24.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTGlowingLabel;

@interface PopNavigationBar : UINavigationBar
{
    UIImageView * navigationBarBackground;
    
    DTGlowingLabel * navigationBarTitle;
}

@property (strong, nonatomic) DTGlowingLabel * navigationBarTitle;

- (void)setBarTitle:(NSString *)_title;

@end
