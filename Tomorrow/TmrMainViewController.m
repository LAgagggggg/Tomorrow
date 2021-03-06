//
//  ViewController.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//
#define OUTSIDE [UIScreen mainScreen].bounds.size
#import "TmrMainViewController.h"

@interface TmrMainViewController ()
@property(strong,nonatomic)NSMutableArray<TmrThing *> * todayThingArr;
@property(strong,nonatomic)NSMutableArray<TmrThing *> * tomorrowThingArr;
@property(strong,nonatomic)MenuView * menu;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property(strong,nonatomic) NSString * archiverPath;
@property(strong,nonatomic) NSString * archiverPathOfTomorrow;
@property(strong,nonatomic) UIView * panReactView;
@property (weak, nonatomic) IBOutlet UIButton *todayAddButton;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;

@property NSInteger originY;
@end

@implementation TmrMainViewController

float TmrAnimationDuration=0.3;
float TmrMaxSwipeLength;

-(NSMutableArray *)todayThingArr{//懒加载今日事项数组
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.archiverPath=[documentPath stringByAppendingPathComponent:@"Tomorrow.data"];
    if (_todayThingArr==nil) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.archiverPath]){
            _todayThingArr=[NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
        }
        else{//若第一次进入则创建示例
            NSUserDefaults * deafults=[NSUserDefaults standardUserDefaults];
            [deafults setObject:[NSDate date] forKey:@"ArrCreatedDate"];
            _todayThingArr=[[NSMutableArray alloc]init];
            TmrThing * thing1=[[TmrThing alloc]initWithTitle:@"滑动完成任务"];
            TmrThing * thing2=[[TmrThing alloc]initWithTitle:@"点击右下角添加任务"];
            TmrThing * thing3=[[TmrThing alloc]initWithTitle:@"点击左下角刷新当前任务"];
            TmrThing * thing4=[[TmrThing alloc]initWithTitle:@"专注于当前任务"];
            [_todayThingArr addObjectsFromArray:@[thing1,thing2,thing3,thing4]];
        }
    }
    return  _todayThingArr;
}

-(NSMutableArray *)tomorrowThingArr{//明日事项数组
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.archiverPathOfTomorrow=[documentPath stringByAppendingPathComponent:@"Tomorrow2.data"];
    if (_tomorrowThingArr==nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.archiverPathOfTomorrow]){
            _tomorrowThingArr=[NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPathOfTomorrow];
        }
        else{
            _tomorrowThingArr=[[NSMutableArray alloc]init];
            TmrThing * thing1=[[TmrThing alloc]initWithTitle:@"这里是为明天准备的任务"];
            TmrThing * thing2=[[TmrThing alloc]initWithTitle:@"零点自动刷新"];
            [_tomorrowThingArr addObjectsFromArray:@[thing1,thing2]];
        }
    }
    return  _tomorrowThingArr;
}

-(void)resetViewWithArr{
    [self checkDateToSwitchArr];
    TmrMaxSwipeLength=[UIScreen mainScreen].bounds.size.width/2;
    self.originY=self.cardView.center.y-64;
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:TmrAnimationDuration animations:^{
            CGRect frame=view.frame;
            frame.origin.y=-OUTSIDE.height;
            view.frame=frame;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TmrAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame=self.cardView.frame;
        frame.origin.x=0;
        self.cardView.frame=frame;
        for (TmrThing * thing in [self.todayThingArr reverseObjectEnumerator]) {
            TmrView * view=[[TmrView alloc]initViewWithThing:thing];
            [self.cardView addSubview:view];
            CGPoint center=self.cardView.center;
            center.x+=10*[self.todayThingArr indexOfObject:thing];
            view.center=center;
            if ([self.todayThingArr indexOfObject:thing]==0) {
                self.panReactView=view;
                UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
                [self.panReactView addGestureRecognizer:pan];
            }
        }
        for (TmrView * view in self.cardView.subviews) {
            CGPoint center=view.center;
            center.y=-OUTSIDE.height;
            view.center=center;
            [UIView animateWithDuration:TmrAnimationDuration animations:^{
                CGPoint center=view.center;
                center.y=self.originY;
                view.center=center;
            }];
        }
    });
}

-(void)checkDateToSwitchArr{//每天将第二天的事项放入当天
    NSDate * previousDate;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    previousDate=[defaults valueForKey:@"ArrCreatedDate"];
    if (previousDate) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *curDateStr=[formatter stringFromDate:[NSDate date]];
        NSString *preDateStr=[formatter stringFromDate:previousDate];
        int preDay=[preDateStr substringWithRange:NSMakeRange(6, 2)].intValue;
        int curDay=[curDateStr substringWithRange:NSMakeRange(6, 2)].intValue;
        NSLog(@"%d--%d",preDay,curDay);
        if (preDay==curDay) {
            //不做什么
        }
        else if (curDay==(preDay+1)||curDay==1){//到了新的一天
            [self.todayThingArr removeAllObjects];
            [self.todayThingArr addObjectsFromArray:self.tomorrowThingArr];
            [self.tomorrowThingArr removeAllObjects];
            [defaults setObject:[NSDate date] forKey:@"ArrCreatedDate"];
        }
        else{//可能超过一天没有打开应用
            [self.todayThingArr removeAllObjects];
            [self.tomorrowThingArr removeAllObjects];
            [defaults setObject:[NSDate date] forKey:@"ArrCreatedDate"];
        }
    }
    else{
        [defaults setValue:[NSDate date] forKey:@"ArrCreatedDate"];
    }
}

-(void)pan:(UIPanGestureRecognizer *)pan{//拖动时的动画效果
    float trans = [pan translationInView:self.panReactView].x;
    float delta = trans * 0.6;
    NSInteger count=self.cardView.subviews.count;
    if (pan.state==UIGestureRecognizerStateChanged) {
        for (TmrView * view in self.cardView.subviews) {
            NSInteger index=self.cardView.subviews.count-[self.cardView.subviews indexOfObject:view]-1;
            view.layer.transform=CATransform3DIdentity;
            view.layer.transform=CATransform3DTranslate(view.layer.transform, delta*(1 - (float)index/count), 0, 0);
            view.layer.transform=CATransform3DRotate(view.layer.transform, (1 - (float)index / (float)count) * (delta / TmrMaxSwipeLength) * (15.0 / 180) * M_PI, 0, 0, 1);
        }
    }
    else if(pan.state==UIGestureRecognizerStateEnded || pan.state==UIGestureRecognizerStateCancelled){
        if (fabsf(trans)>self.panReactView.bounds.size.width/2){//移除第一张卡片
            [UIView animateWithDuration:TmrAnimationDuration animations:^{
                if (trans>=0) {//向右移除
                    self.panReactView.layer.transform=CATransform3DTranslate(self.panReactView.layer.transform, [UIScreen mainScreen].bounds.size.width, 0, 0);
                    self.panReactView.layer.transform=CATransform3DRotate(self.panReactView.layer.transform, M_PI/6, 0, 0, 1);
                }
                else{//向左
                    self.panReactView.layer.transform=CATransform3DTranslate(self.panReactView.layer.transform, -[UIScreen mainScreen].bounds.size.width, 0, 0);
                    self.panReactView.layer.transform=CATransform3DRotate(self.panReactView.layer.transform, M_PI/6, 0, 0, -1);
                }
                self.panReactView.alpha=0;
            } completion:^(BOOL finished) {
                [self didRemoveFirstCard];
            }];
            for (TmrView * view in self.cardView.subviews) {
                if (![view isEqual:self.panReactView]) {
                    view.layer.transform=CATransform3DIdentity;
                }
            }
        }
        else{
            [UIView animateWithDuration:TmrAnimationDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            for (TmrView * view in self.cardView.subviews) {
                view.layer.transform=CATransform3DIdentity;
            }
        } completion:nil];}
    }
}


-(void)didRemoveFirstCard{//将第一张卡片移出画面后要做的事
    [self.todayThingArr removeObjectAtIndex:0];
    [self.panReactView removeFromSuperview];
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:TmrAnimationDuration animations:^{
            CGRect frame=view.frame;
            frame.origin.x-=10;
            view.frame=frame;
        }];
    }
    if (self.todayThingArr.count==0) {
        CGRect frame=self.cardView.frame;
        frame.origin.x=0;
        self.cardView.frame=frame;
    }
    self.panReactView=[self.cardView.subviews lastObject];
    UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.panReactView addGestureRecognizer:pan];
}

- (IBAction)random:(id)sender {
    int random;
    NSMutableArray * randomArr=[[NSMutableArray alloc]init];
    for (TmrThing * thing in self.todayThingArr) {
        random = arc4random() % 2;
        if (random) {
            [randomArr addObject:thing];
        }
        else{
            [randomArr insertObject:thing atIndex:0];
        }
    }
    self.todayThingArr=randomArr;
    [self resetViewWithArr];
    [self saveData];
    
}

- (IBAction)addTodayThing:(id)sender {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TmrAnimationDuration* NSEC_PER_SEC));
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:TmrAnimationDuration animations:^{
            CGRect frame=view.frame;
            frame.origin.x+=10;
            view.frame=frame;
        }];
    }
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        TmrThing * thing=[[TmrThing alloc]initWithTitle:@""];
        TmrView * view=[[TmrView alloc]initViewWithThing:thing];
        [self.todayThingArr insertObject:thing atIndex:0];
        [self.cardView addSubview:view];
        self.panReactView=view;
        UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self.panReactView addGestureRecognizer:pan];
        CGPoint center=self.cardView.center;
        center.y=-OUTSIDE.height;
        view.center=center;
        center.y=self.originY;
        [UIView animateWithDuration:TmrAnimationDuration animations:^{
            view.center=center;
        } completion:^(BOOL finished) {
            [view.title becomeFirstResponder];
        }];
    });
}

-(void)TitleEndEditing{
    for(TmrView *view in self.cardView.subviews)
    {
        for (UITextView * textfield in view.subviews) {
            if ([textfield isFirstResponder]) {
                [textfield resignFirstResponder];
                if (textfield.text.length!=0) {
                    self.todayThingArr[0].title=textfield.text;
                }
                else{
                    CGRect frame=view.frame;
                    frame.origin.y=-OUTSIDE.height;
                    [UIView animateWithDuration:TmrAnimationDuration animations:^{
                        view.frame=frame;
                    } completion:^(BOOL finished) {
                        [self didRemoveFirstCard];
                    }];
                }
            }
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self TitleEndEditing];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.menu]) {
        
    }
    else{
        if (self.menu.frame.origin.x==0) {
            [self CallMenu];
        }
    }
    return NO;
}

- (IBAction)editTomorrowThing:(id)sender {
    TomorrowListViewController * tomorrowVC=[[TomorrowListViewController alloc]initWithArr:self.tomorrowThingArr];
    tomorrowVC.returnArr = ^(NSMutableArray * arr) {
        self.tomorrowThingArr=arr;
    };
    [self.navigationController pushViewController:tomorrowVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.view.backgroundColor=[UIColor whiteColor];
}

-(void)saveData{
    [NSKeyedArchiver archiveRootObject:self.todayThingArr toFile:self.archiverPath];
    [NSKeyedArchiver archiveRootObject:self.tomorrowThingArr toFile:self.archiverPathOfTomorrow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __weak typeof(*&self) weakSelf = self;
    self.appDelegate.dataSaverBlock = ^{
        [weakSelf saveData];
    };
    self.menu=[[MenuView alloc]init];
    __weak typeof(*&self) weakMenu = self;
    self.menu.BrightAdjustblock = ^(float value) {
        [UIView animateWithDuration:0.5 animations:^{
            weakMenu.view.alpha=value;
        }];
    };
    [self resetViewWithArr];
    UIButton * setButton=[[UIButton alloc]initWithFrame:CGRectMake(10,20, 50, 50)];
    [setButton setImage:[UIImage imageNamed:@"setup"] forState:0];
    [setButton addTarget:self action:@selector(CallMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setButton];
    [self.view addSubview:self.menu];
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]init];
    tap.delegate=self;
    [self.cardView addGestureRecognizer:tap];
}

- (void)CallMenu{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f=self.menu.frame;
        if (f.origin.x==0) {
            f.origin.x=-[UIScreen mainScreen].currentMode.size.width/3;
            self.view.alpha=1;
        }
        else{
            f.origin.x=0;
            self.view.alpha=0.5;
        }
        self.menu.frame=f;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
