//
//  MenuView.h
//  MemoryCapturer
//
//  Created by 李嘉银 on 2017/10/29.
//  Copyright © 2017年 lAgagggggg. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MenuView : UIView

@property (strong, nonatomic) UISwitch *switch1;
@property (strong, nonatomic) UISwitch *switch2;
@property (strong, nonatomic) UISwitch *switch3;
@property (strong, nonatomic) void(^BrightAdjustblock)(float value);

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder;


@end
