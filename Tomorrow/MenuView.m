//
//  MenuView.m
//  MemoryCapturer
//
//  Created by 李嘉银 on 2017/10/29.
//  Copyright © 2017年 lAgagggggg. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView

-(instancetype)init{
    self=[super init];
    _switch1=[[UISwitch alloc]init];
    _switch2=[[UISwitch alloc]init];
    _switch3=[[UISwitch alloc]init];
    [self addSubview:_switch1];
    [self addSubview:_switch2];
    [self addSubview:_switch3];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    return self;
}
-(void)pan:(UIPanGestureRecognizer *)pan{
    CGPoint transP = [pan translationInView:self];
    CGRect f=self.frame;
    f.origin.x+=transP.x;
    if (f.origin.x>0) {
        f.origin.x=0;
    }
    float ratio=self.frame.origin.x;
    self.frame=f;
    if(pan.state == UIGestureRecognizerStateEnded){
        if ((f.origin.x+WIDTH)<100) {
            f.origin.x =-WIDTH;
        }
        else{
            f.origin.x =0;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.frame=f;
        }];
    }
    ratio=0.5+(-f.origin.x/WIDTH)*0.5;
    _BrightAdjustblock(ratio);
    [pan setTranslation:CGPointZero inView:self];
}
-(void)layoutSubviews{
    CGRect properframe=CGRectMake(-[UIScreen mainScreen].currentMode.size.width/3, 0,([UIScreen mainScreen].currentMode.size.width)/3, [UIScreen mainScreen].currentMode.size.height);
    self.frame=properframe;
    self.backgroundColor=[UIColor grayColor];
    self.switch1.frame=CGRectMake(10,20, self.switch1.frame.size.width, self.switch1.frame.size.height);
    self.switch2.frame=CGRectMake(10,60, self.switch2.frame.size.width, self.switch2.frame.size.height);
    self.switch3.frame=CGRectMake(10,100, self.switch3.frame.size.width, self.switch3.frame.size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
