//
//  BEARHabitDetailViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/11/1.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARHabitDetailViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "BEARDiaryViewController.h"

@interface BEARHabitDetailViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) BEARHabitItem *habitItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBlockOneLeftAnchro;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBlockTwoLeftAnchor;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBlockThreeLeftAnchor;

@property (weak, nonatomic) IBOutlet UIView *viewBlockOne;
@property (weak, nonatomic) IBOutlet UIView *viewBlockTwo;
@property (weak, nonatomic) IBOutlet UIView *viewBlockThree;

@property (weak, nonatomic) IBOutlet UILabel *viewOneTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewOneNum;
@property (weak, nonatomic) IBOutlet UILabel *viewOneUnit;

@property (weak, nonatomic) IBOutlet UILabel *viewTwoTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewTwoNum;
@property (weak, nonatomic) IBOutlet UILabel *viewTwoUnit;
@property (weak, nonatomic) IBOutlet UILabel *viewThreeTitle;
@property (weak, nonatomic) IBOutlet UILabel *viewThreeNum;
@property (weak, nonatomic) IBOutlet UILabel *viewThreeUnit;

@property (nonatomic, assign) NSInteger totalDay;
@property (nonatomic, assign) NSInteger totalTime;
@property (nonatomic, assign) NSInteger totalNum;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong)  JSContext *jsContext;
@property (weak, nonatomic) IBOutlet UIButton *diaryButton;


@end

@implementation BEARHabitDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                  withHabitItem:(BEARHabitItem*)habitItem
{
    self = [super init];
    if (self) {
        self.habitItem = habitItem;
        self.title = habitItem.name;
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _viewBlockOne.layer.cornerRadius = 5;
    _viewBlockTwo.layer.cornerRadius = 5;
    _viewBlockThree.layer.cornerRadius = 5;
    
    self.diaryButton.layer.cornerRadius = 5;
    self.diaryButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.diaryButton.layer.borderWidth = 1;
    
    _webView.delegate = self;

//    NSURL * url = [NSURL URLWithString:@"http://localhost/~xiongwei/charts/HabitChat.html"];
//    [_webView loadRequest:[NSURLRequest requestWithURL:url]];

    NSString * htmlPath = [[NSBundle mainBundle]pathForResource:@"HabitChat" ofType:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    
    _webView.scrollView.bounces = NO;
    _jsContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    __block NSMutableSet * daySet = [NSMutableSet new];
    [self.habitItem.habitData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, BOOL * _Nonnull stop) {
        [daySet addObject:obj.shortDate];
        self.totalNum += obj.count;
        self.totalTime += obj.time;
    }];
    self.totalDay = daySet.count;
    _viewOneNum.text = [NSString stringWithFormat:@"%ld",_totalDay];
    
    if (_habitItem.isCounter && _habitItem.isTimer) {
        CGFloat divide = (SCREEN_WIDTH - 300)/4.f;
        _viewBlockOneLeftAnchro.constant = divide;
        _viewBlockTwoLeftAnchor.constant = 2*divide + 100;
        _viewBlockThreeLeftAnchor.constant = 3*divide + 200;
        _viewBlockThree.hidden = NO;
        _viewTwoUnit.text = @"次";
        _viewThreeUnit.text = @"分钟";
        _viewTwoNum.text = [NSString stringWithFormat:@"%ld",_totalNum];
        _viewThreeNum.text = [NSString stringWithFormat:@"%ld",_totalTime];
    }
    else if (_habitItem.isCounter && !_habitItem.isTimer) {
        
        CGFloat divide = (SCREEN_WIDTH - 200)/3.f;
        _viewBlockOneLeftAnchro.constant = divide;
        _viewBlockTwoLeftAnchor.constant = 2*divide + 100;
        _viewBlockThree.hidden = YES;
        _viewTwoUnit.text = @"次";
        _viewTwoNum.text = [NSString stringWithFormat:@"%ld",_totalNum];
    }
    else if (!_habitItem.isCounter && _habitItem.isTimer) {
        CGFloat divide = (SCREEN_WIDTH - 200)/3.f;
        _viewBlockOneLeftAnchro.constant = divide;
        _viewBlockTwoLeftAnchor.constant = 2*divide + 100;
        _viewBlockThree.hidden = YES;
        _viewTwoUnit.text = @"分钟";
        _viewTwoNum.text = [NSString stringWithFormat:@"%ld",_totalTime];
    }
    if (self.habitItem.habitData.count == 0) {
        self.diaryButton.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    JSValue * parse = _jsContext[@"render"];
    
    __block NSMutableArray * xAxis = [NSMutableArray new];
    __block NSMutableArray * num = [NSMutableArray new];
    __block NSMutableArray * time = [NSMutableArray new];
    __block NSMutableDictionary<NSString*,NSMutableArray<BEARHabitData*>*> * data = [NSMutableDictionary new];
    
    [self.habitItem.habitData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, BOOL * _Nonnull stop) {
         NSMutableArray<BEARHabitData*> * dayData = [data valueForKey:obj.shortDate];
        if (!dayData) {
            dayData = [[NSMutableArray alloc]init];
        }
        [dayData addObject:obj];
        [data setValue:dayData forKey:obj.shortDate];
    }];
    
    NSArray * sortShortData = [data.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (obj1 > obj2) {
            return NSOrderedDescending;
        }
        else{
            return NSOrderedAscending;
        }
    }];
    
    [sortShortData enumerateObjectsUsingBlock:^(id  _Nonnull objKey, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<BEARHabitData *> * _Nonnull obj = [data valueForKey:objKey];
        [xAxis addObject:objKey];
        __block NSInteger dayTotalNum = 0;
        __block NSInteger dayTotalTime = 0;
        [obj enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull objData, NSUInteger idx, BOOL * _Nonnull stop) {
            dayTotalNum += objData.count;
            dayTotalTime += objData.time;
        }];
        [num addObject:@(dayTotalNum)];
        [time addObject:@(dayTotalTime)];
    }];
    
    NSDictionary * param;
    if (_habitItem.isTimer && _habitItem.isCounter) {
        param = @{@"xAxis":xAxis,@"num":num,@"time":time};
    }
    else if(_habitItem.isTimer && !_habitItem.isCounter){
        param = @{@"xAxis":xAxis,@"time":time};
    }
    else if(!_habitItem.isTimer && _habitItem.isCounter){
        param = @{@"xAxis":xAxis,@"num":num};
    }
    [parse callWithArguments:@[param]];
}

- (IBAction)onDiaryButtonClicked:(id)sender {
    BEARDiaryViewController * diaryVC = [[BEARDiaryViewController alloc]initWithHabitItem:_habitItem];
    [self.navigationController pushViewController:diaryVC animated:YES];
}

@end
