//
//  ViewController.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//
#define OUTSIDE [UIScreen mainScreen].bounds.size
#import "ViewController.h"

@interface ViewController ()
@property(strong,nonatomic)NSMutableArray<TmrThing *> * todayThingArr;
@property(strong,nonatomic)NSMutableArray<TmrThing *> * tomorrowThingArr;
@property(strong,nonatomic)MenuView * menu;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property(strong,nonatomic) NSString * archiverPath;
@property(strong,nonatomic) NSString * archiverPathOfTomorrow;
@property(strong,nonatomic) UIView * panReactView;
@property (weak, nonatomic) IBOutlet UIButton *todayAddButton;
@property (weak, nonatomic) IBOutlet UIButton *tomorrowAddButton;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property NSInteger originY;
@end

@implementation ViewController

-(NSMutableArray *)todayThingArr{
    if (_todayThingArr==nil) {
        NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.archiverPath=[documentPath stringByAppendingPathComponent:@"Tomorrow.data"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.archiverPath]){
            _todayThingArr=[NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
        }
        else{
            _todayThingArr=[[NSMutableArray alloc]init];
            NSInteger i;
            for (i=0; i<11; i++) {
                TmrThing * thing=[[TmrThing alloc]initWithTitle:[NSString stringWithFormat:@"%lu",i]];
                [_todayThingArr addObject:thing];
            }
        }
    }
    return  _todayThingArr;
}

-(NSMutableArray *)tomorrowThingArr{
    if (_tomorrowThingArr==nil) {
        NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.archiverPathOfTomorrow=[documentPath stringByAppendingPathComponent:@"Tomorrow2.data"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.archiverPathOfTomorrow]){
            _tomorrowThingArr=[NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPathOfTomorrow];
        }
        else{
            _tomorrowThingArr=[[NSMutableArray alloc]init];
            NSInteger i;
            for (i=0; i<4; i++) {
                TmrThing * thing=[[TmrThing alloc]initWithTitle:[NSString stringWithFormat:@"%lu",i]];
                [_tomorrowThingArr addObject:thing];
            }
        }
    }
    return  _tomorrowThingArr;
}

-(void)setViewWithArr{
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4* NSEC_PER_SEC));
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame=view.frame;
            frame.origin.y=-OUTSIDE.height;
            view.frame=frame;
        }];
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
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
                self.originY=self.cardView.center.y-self.panReactView.frame.size.height/2-64;
            }
        }
        for (TmrView * view in self.cardView.subviews) {
            CGRect frame=view.frame;
            frame.origin.y=-OUTSIDE.height;
            view.frame=frame;
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame=view.frame;
                frame.origin.y=self.originY;
                view.frame=frame;
            }];
        }
    });
}

-(void)pan:(UIPanGestureRecognizer *)pan{
    NSInteger removeJudge=0;
    CGPoint transP = [pan translationInView:self.panReactView];
    CGRect f=self.panReactView.frame;
    f.origin.y+=transP.y;
    if (f.origin.y>self.originY) {
        f.origin.y=self.originY;
    }
    self.panReactView.frame=f;
    if(pan.state == UIGestureRecognizerStateEnded){
        if (f.origin.y<-[UIScreen mainScreen].bounds.size.height*1/3) {
            f.origin.y=-OUTSIDE.height;
            removeJudge=1;
        }
        else{
            f.origin.y=self.originY;
        }
        [UIView animateWithDuration:0.4 animations:^{
            self.panReactView.frame=f;
        }];
        if (removeJudge==1) {
            [self performSelector:@selector(didRemoveFirstCard) withObject:nil afterDelay:0.4];
        }
    }
    [pan setTranslation:CGPointZero inView:self.panReactView];
}

-(void)didRemoveFirstCard{
    [self.todayThingArr removeObjectAtIndex:0];
    [self.panReactView removeFromSuperview];
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:0.4 animations:^{
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
    int random = arc4random() % 2;
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
    [self setViewWithArr];
    [self saveData];
    
}

- (IBAction)addTodayThing:(id)sender {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4* NSEC_PER_SEC));
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:0.4 animations:^{
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
        center.y=self.originY+view.frame.size.height/2;
        [UIView animateWithDuration:0.4 animations:^{
            view.center=center;
        }];
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [view.title becomeFirstResponder];
        });
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
                    [UIView animateWithDuration:0.4 animations:^{
                        view.frame=frame;
                    }];
                    [self performSelector:@selector(didRemoveFirstCard) withObject:nil afterDelay:0.5];
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
    TomorrowListViewController * tomorrow=[[TomorrowListViewController alloc]initWithArr:self.tomorrowThingArr];
    tomorrow.returnArr = ^(NSMutableArray * arr) {
        self.tomorrowThingArr=arr;
    };
    [self.navigationController pushViewController:tomorrow animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
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
    [self setViewWithArr];
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
