//
//  TomorrowListViewController.m
//  Tomorrow
//
//  Created by 李嘉银 on 2017/11/10.
//  Copyright © 2017年 李嘉银. All rights reserved.
//
#define OUTSIDE [UIScreen mainScreen].bounds.size
#import "TomorrowListViewController.h"

@interface TomorrowListViewController ()
@property(strong,nonatomic)UIScrollView * scrollView;
@property(strong,nonatomic)NSMutableArray<TmrThing *> * thingArr;
@property(strong,nonatomic)NSMutableArray<TmrCell *> * cellArr;
@property CGFloat currentY;
@end

@implementation TomorrowListViewController

-(NSMutableArray *)cellArr{
    if (_cellArr==nil) {
        _cellArr=[[NSMutableArray alloc]init];
    }
    return _cellArr;
}

-(NSMutableArray *)thingArr{
    if (_thingArr==nil) {
        _thingArr=[[NSMutableArray alloc]init];
    }
    return _thingArr;
}

-(instancetype)initWithArr:(NSMutableArray *)arr{
    self=[super init];
    self.thingArr=arr;
    self.scrollView=[[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.backgroundColor=[UIColor clearColor];
    UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc]init];
    tap.delegate=self;
    [self.scrollView addGestureRecognizer:tap];
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor=[UIColor whiteColor];
    UIButton * addButton=[[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-50-10, [UIScreen mainScreen].bounds.size.height-50-20, 50, 50)];
    [addButton setImage:[UIImage imageNamed:@"addition"] forState:0];
    [addButton addTarget:self action:@selector(AddTomorrowThing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    UIButton * returnButton=[[UIButton alloc]initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height-50-20, 50, 50)];
    [returnButton setImage:[UIImage imageNamed:@"return"] forState:0];
    [returnButton addTarget:self action:@selector(ReturnToToday) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnButton];
    for (TmrThing * thing in self.thingArr) {
        TmrCell * cell=[[TmrCell alloc]init];
        cell.title.text=thing.title;
        [self CalCurrentY];
        [self.scrollView addSubview:cell];
        UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [cell addGestureRecognizer:pan];
        CGPoint center=CGPointMake(-400, self.currentY);
        cell.center=center;
        center.x=self.view.center.x;
        [self.cellArr addObject:cell];
        [UIView animateWithDuration:0.8 animations:^{
            cell.center=center;
        }];
    }
//    self.navigationItem.hidesBackButton=YES;
    return self;
}

-(void)pan:(UIPanGestureRecognizer *)pan{
    NSLog(@"%@",pan.view);
//    NSInteger removeJudge=0;
//    CGPoint transP = [pan translationInView:self.panReactView];
//    CGRect f=self.panReactView.frame;
//    f.origin.y+=transP.y;
//    if (f.origin.y>self.originY) {
//        f.origin.y=self.originY;
//    }
//    self.panReactView.frame=f;
//    if(pan.state == UIGestureRecognizerStateEnded){
//        if (f.origin.y<-[UIScreen mainScreen].bounds.size.height*1/3) {
//            f.origin.y=-OUTSIDE.height;
//            removeJudge=1;
//        }
//        else{
//            f.origin.y=self.originY;
//        }
//        [UIView animateWithDuration:0.4 animations:^{
//            self.panReactView.frame=f;
//        }];
//        if (removeJudge==1) {
//            [self performSelector:@selector(didRemoveFirstCard) withObject:nil afterDelay:0.4];
//        }
//    }
//    [pan setTranslation:CGPointZero inView:self.panReactView];
}

-(void)AddTomorrowThing{
    [self CalCurrentY];
    TmrCell * cell=[[TmrCell alloc]init];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [cell addGestureRecognizer:pan];
    [self.scrollView addSubview:cell];
    CGPoint center=CGPointMake(-400, self.currentY);
    cell.center=center;
    center.x=self.view.center.x;
    [UIView animateWithDuration:0.4 animations:^{
        cell.center=center;
    }];
    [self.cellArr addObject:cell];
    [cell.title becomeFirstResponder];
}

-(void)ReturnToToday{
    [self.thingArr removeAllObjects];
    for (TmrCell * cell in self.cellArr) {
        TmrThing * thing=[[TmrThing alloc]initWithTitle:cell.title.text];
        [self.thingArr addObject:thing];
    }
    self.returnArr(self.thingArr);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)TitleEndEditing{
    for(TmrCell * cell in self.cellArr)
    {
        if ([cell.title isFirstResponder]) {
            [cell.title resignFirstResponder];
            if (cell.title.text.length==0) {
                CGRect frame=cell.frame;
                frame.origin.x=-OUTSIDE.width;
                [UIView animateWithDuration:0.4 animations:^{
                    cell.frame=frame;
                }];
                [self.cellArr removeObject:cell];
                [cell performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:
                     0.4];
            }
        }
    }
}

-(void)CalCurrentY{
    self.currentY=100;
    for (TmrCell * cell in self.cellArr) {
        self.currentY+=cell.frame.size.height+5;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isFirstResponder]) {
        
    }
    else{
        [self TitleEndEditing];
    }
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
