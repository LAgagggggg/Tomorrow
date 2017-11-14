//
//  MenuView.h
//  MemoryCapturer
//
//  Created by 李嘉银 on 2017/10/29.
//  Copyright © 2017年 lAgagggggg. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WIDTH ([UIScreen mainScreen].currentMode.size.width/3)
@interface MenuView : UIView

@property (strong, nonatomic) UISwitch *switch1;
@property (strong, nonatomic) UISwitch *switch2;
@property (strong, nonatomic) UISwitch *switch3;
@property (strong, nonatomic) void(^BrightAdjustblock)(float value);

@end
