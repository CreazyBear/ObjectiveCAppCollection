//
//  BEARMineViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/10/31.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARMineViewController.h"
#import "BEARHabitDetailViewController.h"
#import "BEARMineTableViewCell.h"
#import "BEARSettingViewController.h"
#import "BEARNewHabitViewController.h"

@interface BEARMineViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL shouldUpdata;
@property (nonatomic, strong) NSMutableArray<BEARHabitItem*> *dataSource;

@property (nonatomic, strong) NSMutableArray<BEARHabitItem*> *endedHabit;
@property (nonatomic, strong) NSMutableArray<BEARHabitItem*> *ingHabit;
@property (nonatomic, strong) UIView *emptyView;
@end

@implementation BEARMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.endedHabit = [NSMutableArray new];
    self.ingHabit = [NSMutableArray new];
    [self setupNavRightButton];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"BEARMineTableViewCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([BEARMineTableViewCell class])];
    [self.view addSubview:self.emptyView];
    self.shouldUpdata = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:deleteDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:saveDataNotification object:nil];

}

-(UIView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _emptyView.backgroundColor = BackgroundColor;
        UILabel * label = [[UILabel alloc]init];
        label.text = @"空空如野~！新建一个习惯吧~";
        [_emptyView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label.centerXAnchor constraintEqualToAnchor:_emptyView.centerXAnchor].active = YES;
        [label.centerYAnchor constraintEqualToAnchor:_emptyView.centerYAnchor].active = YES;
        
        UIButton * newHabitButton = [UIButton new];
        [newHabitButton setTitle:@"新的征程" forState:(UIControlStateNormal)];
        [newHabitButton addTarget:self action:@selector(newHabit) forControlEvents:(UIControlEventTouchUpInside)];
        [newHabitButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        newHabitButton.layer.cornerRadius = 5;
        newHabitButton.backgroundColor = [UIColor orangeColor];
        newHabitButton.translatesAutoresizingMaskIntoConstraints = NO;
        newHabitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_emptyView addSubview:newHabitButton];
        
        [newHabitButton.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:20].active = YES;
        [newHabitButton.centerXAnchor constraintEqualToAnchor:label.centerXAnchor].active = YES;
        [newHabitButton.widthAnchor constraintEqualToConstant:150].active = YES;
        _emptyView.hidden = YES;
    }
    return _emptyView;
}

-(void)newHabit{
    BEARNewHabitViewController * newHabitVC = [[BEARNewHabitViewController alloc]init];
    [self.navigationController pushViewController:newHabitVC animated:YES];
}

-(void)dataBaseUpdate
{
    self.shouldUpdata = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_shouldUpdata) {
        _shouldUpdata = NO;
        [self setupDataSource];
        [_tableView reloadData];
    }
    
}

-(void)setupDataSource
{
    [self.dataSource removeAllObjects];
    [self.endedHabit removeAllObjects];
    [self.ingHabit removeAllObjects];
    [[BEARDatabaseManager share] readEntity:habitItemEntityName
                               sequenceKeys:nil
                                  ascending:YES
                            filterPredicate:nil
                                    success:^(NSArray<BEARHabitItem*> *results) {
                                        self.dataSource = [results mutableCopy];
                                        [results enumerateObjectsUsingBlock:^(BEARHabitItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            if (obj.isHasEnd && [obj.endTime isInPast]) {
                                                [self.endedHabit addObject:obj];
                                            }
                                            else{
                                                [self.ingHabit addObject:obj];
                                            }
                                        }];
                                        if (_dataSource.count == 0) {
                                            self.emptyView.hidden = NO;
                                        }
                                        else{
                                            self.emptyView.hidden = YES;
                                        }
                                    } fail:^(NSError *error) {
                                        NSLog(@"%@",error);
                                    }];
}


- (void)viewDidAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}


-(void)setting{
    [self.navigationController pushViewController:[BEARSettingViewController new] animated:YES];
}

-(void)setupNavRightButton
{
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(setting)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.ingHabit.count;
    }
    else{
        return self.endedHabit.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BEARMineTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.textLabel.text = self.ingHabit[indexPath.row].name;
    }
    else{
        cell.textLabel.text = self.endedHabit[indexPath.row].name;
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"正在进行时";
    }
    else{
        return @"过去式";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 28.0)];
    customView.backgroundColor = BackgroundColor;
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor lightGrayColor];
    headerLabel.highlightedTextColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    headerLabel.frame = CGRectMake(17.0, 0.0,SCREEN_WIDTH, 28.0);
    if (section == 0) {
        headerLabel.text = @"正在进行时";
    }
    else{
        headerLabel.text = @"过去式";
    }
    [customView addSubview:headerLabel];
    return customView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BEARHabitItem * habitItem;
    if (indexPath.section == 0) {
        habitItem = self.ingHabit[indexPath.row];
    }
    else{
        habitItem = self.endedHabit[indexPath.row];
    }
    BEARHabitDetailViewController * detailVC = [[BEARHabitDetailViewController alloc]initWithNibName:@"BEARHabitDetailViewController" bundle:nil withHabitItem:habitItem];
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
@end
