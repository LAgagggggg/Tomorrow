//
//  ViewController.h
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TmrThing.h"
#import "TmrView.h"
#import "MenuView.h"
#import "TomorrowListViewController.h"

@interface ViewController : UIViewController<UITextViewDelegate,UIGestureRecognizerDelegate>

@property(strong,nonatomic)AppDelegate *appDelegate;

@end

