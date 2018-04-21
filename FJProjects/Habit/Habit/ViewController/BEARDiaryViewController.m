//
//  BEARDiaryViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDiaryViewController.h"
#import "BEARDiaryTableViewCell.h"
#import "BEARDiaryDetailViewController.h"
#import "BEARDiaryModel.h"

@interface BEARDiaryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) BEARHabitItem *habitItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<BEARHabitData*> * dataSource ;
@end

@implementation BEARDiaryViewController

- (instancetype)initWithHabitItem:(BEARHabitItem*)item
{
    self = [super init];
    if (self) {
        self.habitItem = item;
        
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
    self.title = @"日记";
    self.view.backgroundColor = BackgroundColor;
    self.dataSource = [self.habitItem.habitData allObjects].mutableCopy;
    [self.dataSource sortUsingComparator:^NSComparisonResult(BEARHabitData* obj1, BEARHabitData* obj2) {
        if ([obj1.date isEarlierThanDate: obj2.date]) {
            return NSOrderedDescending;
        }
        else{
            return NSOrderedAscending;
        }
    }];
    NSMutableArray * tempDataSource = [NSMutableArray new];
    [self.dataSource enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.diary isNilOrEmpty]) {
            BEARDiaryModel * model = [BEARDiaryModel yy_modelWithJSON:obj.diary];
            if (!model) {
                [tempDataSource addObject:obj];
            }
            else if ((model.img && model.img.count) || ![model.text isNilOrEmpty]) {
                [tempDataSource addObject:obj];
            }
            
        }
    }];
    self.dataSource = tempDataSource;
    [self setupHabitTable];
}


-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = BackgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"BEARDiaryTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([BEARDiaryTableViewCell class])];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

-(void)setupHabitTable
{
    [self.view addSubview:self.tableView];
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-SafeAreaBottomHeight-BottomBarHeight].active = YES;
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARDiaryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BEARDiaryTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell bindData:self.dataSource[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARDiaryDetailViewController * vc = [[BEARDiaryDetailViewController alloc]initWithItem:self.dataSource[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
