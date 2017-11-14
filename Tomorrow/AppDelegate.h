//
//  AppDelegate.h
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic)void(^dataSaverBlock)(void);

@end

