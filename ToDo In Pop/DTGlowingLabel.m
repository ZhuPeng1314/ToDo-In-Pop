//
//  DTGlowingLabel.m
//  ToDo In Pop
//
//  Created by 鹏 朱 on 15-9-14.
//  Copyright (c) 2015年 MiaoMiao. All rights reserved.
//

#import "DTGlowingLabel.h"

@implementation DTGlowingLabel

@synthesize insideColor  = _insideColor;
@synthesize outLineColor = _outLineColor;
@synthesize blurColor    = _blurColor;
- (id) init
{
    if(self=[super init])
    {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetStrokeColorWithColor(ctx, _outLineColor.CGColor);
    //CGContextSetFillColorWithColor(ctx, _insideColor.CGColor);
    //填充颜色和描边颜色不影响NSString的drawInRect，颜色需要在它的属性NSForegroundColorAttributeName和NSStrokeColorAttributeName中设置

    CGContextSetLineWidth(ctx, self.font.pointSize/30.0);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), self.font.pointSize / 5, _blurColor.CGColor);
    CGTextDrawingMode mode = (_outLineColor==nil)? kCGTextFill: ((_insideColor==nil)? kCGTextStroke : kCGTextFillStroke);
    CGContextSetTextDrawingMode(ctx, mode);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    NSMutableDictionary * attributes = [[NSMutableDictionary alloc] init];
    attributes[NSFontAttributeName] = self.font;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    if (_insideColor != nil)
    {
        attributes[NSForegroundColorAttributeName] = _insideColor;
    }
    
    if (_outLineColor != nil) {
        attributes[NSStrokeColorAttributeName] = _outLineColor;
    }
    
    [self.text drawInRect:self.bounds withAttributes:attributes];
    
}


@end
