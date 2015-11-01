//
//  DTGlowingLabel.h
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-14.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTGlowingLabel : UILabel
{
    UIColor *_outLineColor;

    UIColor *_insideColor;
    
    UIColor *_blurColor;
}

@property (nonatomic, retain) UIColor *outLineColor;
@property (nonatomic, retain) UIColor *insideColor;
@property (nonatomic, retain) UIColor *blurColor;

@end
