//
//  ViewController.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/9.
//  Copyright © 2017年 李嘉银. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong,nonatomic)NSMutableArray<TmrThing *> * thingArr;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property(strong,nonatomic) NSString * archiverPath;
@property(strong,nonatomic) UIView * panReactView;
@property NSInteger originY;
@end

@implementation ViewController

-(NSMutableArray *)thingArr{
    if (_thingArr==nil) {
        NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.archiverPath=[documentPath stringByAppendingPathComponent:@"Tomorrow.data"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:self.archiverPath]){
            _thingArr=[NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
        }
        else{
            _thingArr=[[NSMutableArray alloc]init];
            NSInteger i;
            for (i=0; i<11; i++) {
                TmrThing * thing=[[TmrThing alloc]initWithTitle:[NSString stringWithFormat:@"%lu",i]];
                [_thingArr addObject:thing];
            }
        }
    }
    return  _thingArr;
}
-(void)setViewWithArr{
    for (TmrThing * thing in [self.thingArr reverseObjectEnumerator]) {
        TmrView * view=[[TmrView alloc]initViewWithThing:thing];
        [self.cardView addSubview:view];
        CGPoint center=self.cardView.center;
        center.x+=10*[self.thingArr indexOfObject:thing];
        view.center=center;
        if ([self.thingArr indexOfObject:thing]==0) {
            self.panReactView=view;
            UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
            [self.panReactView addGestureRecognizer:pan];
            self.originY=self.cardView.center.y-self.panReactView.frame.size.height/2;
        }
    }
    for (TmrView * view in self.cardView.subviews) {
        CGRect frame=view.frame;
        frame.origin.y=-500;
        view.frame=frame;
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame=view.frame;
            frame.origin.y=self.originY;
            view.frame=frame;
        }];
    }
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
            f.origin.y=-500;
            removeJudge=1;
        }
        else{
            f.origin.y=self.originY;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.panReactView.frame=f;
        }];
        if (removeJudge==1) {
            [self performSelector:@selector(didRemoveFirstCard) withObject:nil afterDelay:0.4];
        }
    }
    [pan setTranslation:CGPointZero inView:self.panReactView];
}

-(void)didRemoveFirstCard{
    [self.thingArr removeObjectAtIndex:0];
    [self.panReactView removeFromSuperview];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint center=self.cardView.center;
        center.x-=10;
        self.cardView.center=center;
    }];
    if (self.thingArr.count==0) {
        CGRect frame=self.cardView.frame;
        frame.origin.x=0;
        self.cardView.frame=frame;
    }
    self.panReactView=[self.cardView.subviews lastObject];
    NSLog(@"%@",[self.cardView.subviews lastObject]);
    UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.panReactView addGestureRecognizer:pan];
}

- (IBAction)random:(id)sender {
    int random = arc4random() % 2;
    NSMutableArray * randomArr=[[NSMutableArray alloc]init];
    for (TmrThing * thing in self.thingArr) {
        random = arc4random() % 2;
        if (random) {
            [randomArr addObject:thing];
        }
        else{
            [randomArr insertObject:thing atIndex:0];
        }
    }
    self.thingArr=randomArr;
    for (TmrView * view in self.cardView.subviews) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame=view.frame;
            frame.origin.y=-500;
            view.frame=frame;
        }];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4* NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }
    CGRect frame=self.cardView.frame;
    frame.origin.x=0;
    self.cardView.frame=frame;
    [self performSelector:@selector(setViewWithArr) withObject:nil afterDelay:0.4];
    [self performSelector:@selector(saveData) withObject:nil afterDelay:0.4];
}

-(void)saveData{
    [NSKeyedArchiver archiveRootObject:self.thingArr toFile:self.archiverPath];
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.backgroundColor=[UIColor whiteColor];
    [self setViewWithArr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __weak typeof(*&self) weakSelf = self;
    self.appDelegate.appTerminated = ^{
        [weakSelf saveData];
    };
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
