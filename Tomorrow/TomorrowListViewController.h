//
//  TomorrowListViewController.h
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/10.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TmrCell.h"
#import "TmrThing.h"

@interface TomorrowListViewController : UIViewController<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property(strong,nonatomic)void(^returnArr)(NSMutableArray * arr);

-(instancetype)initWithArr:(NSMutableArray*)arr;

@end
