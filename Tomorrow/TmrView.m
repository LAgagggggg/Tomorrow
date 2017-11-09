//
//  TmrView.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import "TmrView.h"

@implementation TmrView

-(TmrView *)initViewWithThing:(TmrThing *)thing{
    self=[super init];
    self.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*2/3, [UIScreen mainScreen].bounds.size.height*2/3);
    self.backgroundColor=[UIColor orangeColor];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;
    self.layer.cornerRadius =20;
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOpacity=0.5;
    maskLayer.shadowRadius=4.f;
    self.layer.shadowOffset = CGSizeMake(4,4);
    UILabel * title =[[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/8, self.bounds.size.height*3/8, self.bounds.size.width*3/4, 50)];
    title.text=thing.title;
    [title setTextColor:[UIColor blackColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont systemFontOfSize:30 weight:UIFontWeightHeavy]];
    [self addSubview:title];
    return self;
}

@end
