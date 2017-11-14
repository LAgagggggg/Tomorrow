//
//  TmrCell.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/12.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import "TmrCell.h"

@implementation TmrCell

-(TmrCell *)init{
    self=[super init];
    self.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*2/3, 40);
    self.backgroundColor=[UIColor orangeColor];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    //    self.layer.mask = maskLayer;
    self.layer.cornerRadius =10;
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOpacity=0.5;
    maskLayer.shadowRadius=4.f;
    self.layer.shadowOffset = CGSizeMake(3,3);
    self.title =[[UITextView alloc]initWithFrame:self.frame];
    [self.title setTextColor:[UIColor blackColor]];
    [self.title setTextAlignment:NSTextAlignmentCenter];
    [self.title setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightHeavy]];
    self.title.backgroundColor=[UIColor clearColor];
    self.title.scrollEnabled=NO;
    [self addSubview:self.title];
    return self;
}

@end
