//
//  BEARHabitCalendarViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/10/17.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARHabitCalendarViewController.h"
#import <FSCalendar.h>
#import "BEARHabitCalendarTableViewCell.h"
#import "BEARHabitDetailViewController.h"

@interface BEARHabitCalendarViewController ()<FSCalendarDelegate,FSCalendarDataSource,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<BEARHabitData*> *dataSource;
@property (nonatomic, strong) NSMutableArray<BEARHabitItem*> *habitItems;
@property (nonatomic, strong) FSCalendar *calendar;
@property (nonatomic, assign) BOOL shouldUpdata;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation BEARHabitCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.shouldUpdata = YES;
    self.dataSource = [NSMutableArray new];
    self.habitItems = [NSMutableArray new];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyView];
    self.selectedDate = [NSDate new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:deleteDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:saveDataNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_shouldUpdata) {
        _shouldUpdata = NO;
        [self setupDataSource];
        [self.tableView reloadData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dataBaseUpdate
{
    self.shouldUpdata = YES;
}


-(void)setupDataSource
{
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"shortDate = %@", self.selectedDate.shortDateString];
    [[BEARDatabaseManager share] readEntity:habitDataEntityName
                               sequenceKeys:nil
                                  ascending:YES
                            filterPredicate:filterPredicate
                                    success:^(NSArray<BEARHabitData*> *results) {
                                        self.dataSource = [results mutableCopy];
                                        [results enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            if (obj.habit && ![_habitItems containsObject:obj.habit]) {
                                                [_habitItems addObject:obj.habit];
                                            }
                                        }];
                                        if (_habitItems.count == 0) {
                                            self.emptyView.hidden = NO;
                                        }
                                        else{
                                            self.emptyView.hidden = YES;
                                        }
                                    } fail:^(NSError *error) {
                                        NSLog(@"%@",error);
                                    }];
}


-(FSCalendar *)calendar{
    if (!_calendar) {
        
        _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _calendar.dataSource = self;
        _calendar.delegate = self;
        _calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        _calendar.backgroundColor = [UIColor whiteColor];
    }
    return _calendar;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BottomBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = BackgroundColor;
        _tableView.tableHeaderView = self.calendar;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"BEARHabitCalendarTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([BEARHabitCalendarTableViewCell class])];
    }
    return _tableView;
}

-(UIView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 300+SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-BottomBarHeight-300)];
        _emptyView.backgroundColor = BackgroundColor;
        UILabel * label = [[UILabel alloc]init];
        label.text = @"没有打卡记录~，换一天吧 =。=";
        [_emptyView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label.centerXAnchor constraintEqualToAnchor:_emptyView.centerXAnchor].active = YES;
        [label.centerYAnchor constraintEqualToAnchor:_emptyView.centerYAnchor].active = YES;
        _emptyView.hidden = YES;
    }
    return _emptyView;
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.habitItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARHabitCalendarTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BEARHabitCalendarTableViewCell class]) forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell bindData:self.habitItems[indexPath.row] currentDate:self.dataSource];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARHabitDetailViewController * detailVC = [[BEARHabitDetailViewController alloc]initWithNibName:@"BEARHabitDetailViewController" bundle:nil withHabitItem:self.habitItems[indexPath.row]];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - FSCalendarDelegate,FSCalendarDataSource
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    self.selectedDate = date;
    [self.habitItems removeAllObjects];
    [self.dataSource removeAllObjects];
    [self setupDataSource];
    [self.tableView reloadData];
}

@end
