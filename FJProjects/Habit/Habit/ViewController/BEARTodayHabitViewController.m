//
//  BEARTodayHabitViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/10/17.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARTodayHabitViewController.h"
#import "BEARNewHabitViewController.h"
#import "BEARTableViewCell.h"
#import "BEARDIDIViewController.h"
#import "BEARHabitDetailViewController.h"

@interface BEARTodayHabitViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *habitTable;
@property (nonatomic, strong) NSMutableArray<BEARHabitItem*> *dataSource;
@property (nonatomic, assign) BOOL shouldUpdata;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, assign) BOOL isEditList;
@end

@implementation BEARTodayHabitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:BackgroundColor];
    [self setupNavRightButton];
    [self setupHabitTable];
    self.shouldUpdata = YES;
    self.isEditList = NO;
    [self.view addSubview:self.emptyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:deleteDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataBaseUpdate) name:saveDataNotification object:nil];
}

- (void)setUpLocalNotification:(NSDate *)fireDate
                withHabiteItem:(BEARHabitItem*)item
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil) {
        return;
    }
    
    //设置UILocalNotification
    [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];//设置时区
    localNotification.fireDate = fireDate;//设置触发时间
    localNotification.repeatInterval = kCFCalendarUnitDay;//设置重复间隔
    localNotification.timeZone=[NSTimeZone defaultTimeZone];
    if (item.habitData.count == 0) {
        localNotification.alertBody = [NSString stringWithFormat:@"打卡时间到~！开启征程吧~(๑˃̵ᴗ˂̵)و"];
    }
    else{
        localNotification.alertBody = [NSString stringWithFormat:@"打卡时间到~！已经累计打卡%ld次了~(๑˃̵ᴗ˂̵)و",item.habitData.count];
    }
    
    localNotification.alertTitle = item.name;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    localNotification.applicationIconBadgeNumber += 1;
    localNotification.userInfo = @{
                                   @"title" : localNotification.alertTitle,
                                   @"body":localNotification.alertBody
                                   };
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [_habitTable reloadData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = NO;
}

-(void)setupNavRightButton
{
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"新建"
                                                                     style:(UIBarButtonItemStylePlain)
                                                                    target:self
                                                                    action:@selector(newHabit)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)setupDataSource
{
    [[BEARDatabaseManager share] readEntity:habitItemEntityName
                               sequenceKeys:nil
                                  ascending:YES
                            filterPredicate:nil
                                    success:^(NSArray<BEARHabitItem*> *results) {
                                        self.dataSource = [results mutableCopy];
                                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                                        [results enumerateObjectsUsingBlock:^(BEARHabitItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            if (obj.isHasEnd && [obj.endTime isInPast]) {
                                                [self.dataSource removeObject:obj];
                                            }
                                            else if(obj.isHasEnd && [obj.endTime isInFuture])
                                            {
                                                if (obj.isNotify) {
                                                    [self setUpLocalNotification:obj.notifyTime withHabiteItem:obj];
                                                }
                                            }
                                            else if(!obj.isHasEnd){
                                                if (obj.isNotify) {
                                                    [self setUpLocalNotification:obj.notifyTime withHabiteItem:obj];
                                                }
                                            }
                                            
                                        }];
                                        if (self.dataSource.count == 0) {
                                            self.emptyView.hidden = NO;
                                        }
                                        else{
                                            self.emptyView.hidden = YES;
                                        }
                                    } fail:^(NSError *error) {
                                        NSLog(@"%@",error);
                                    }];
}


-(UITableView *)habitTable
{
    if (!_habitTable) {
        _habitTable = [[UITableView alloc]init];
        _habitTable.backgroundColor = BackgroundColor;
        _habitTable.delegate = self;
        _habitTable.dataSource = self;
        _habitTable.showsVerticalScrollIndicator = NO;
        _habitTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_habitTable registerClass:[BEARTableViewCell class]
            forCellReuseIdentifier:NSStringFromClass([BEARTableViewCell class])];
        _habitTable.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _habitTable;
}

-(void)setupHabitTable
{
    [self.view addSubview:self.habitTable];
    [self.habitTable.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.habitTable.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.habitTable.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.habitTable.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-SafeAreaBottomHeight-BottomBarHeight].active = YES;
    
}

-(UIView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]initWithFrame:self.view.frame];
        _emptyView.backgroundColor = BackgroundColor;
        UILabel * label = [[UILabel alloc]init];
        label.text = @"空空如野~！新建一个习惯吧~";
        [_emptyView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label.centerXAnchor constraintEqualToAnchor:_emptyView.centerXAnchor].active = YES;
        [label.centerYAnchor constraintEqualToAnchor:_emptyView.centerYAnchor].active = YES;
        _emptyView.hidden = YES;
    }
    return _emptyView;
}

-(void)newHabit
{
    BEARNewHabitViewController * newHabitVC = [[BEARNewHabitViewController alloc]initWithExistHabits:self.dataSource];
    [self.navigationController pushViewController:newHabitVC animated:YES];
}

-(void)editList{
    self.isEditList = !self.isEditList;
    [self.habitTable setEditing:self.isEditList animated:YES];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource?_dataSource.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BEARTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell bindData:self.dataSource?self.dataSource[indexPath.row]:nil];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEARHabitItem * data = _dataSource[indexPath.row];
    if (data.isTimer && data.isCounter) {
        return 180;
    }
    else{
        return 130;
    }
    
    
    return 200;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *didiRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"详情" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self jumpToDetailPageWithIndexPath:indexPath];
    }];
    [didiRowAction setBackgroundColor:[UIColor redColor]];
    
    
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        BEARNewHabitViewController * newHabitVC = [[BEARNewHabitViewController alloc]initWithModify:self.dataSource[indexPath.row]];
        [self.navigationController pushViewController:newHabitVC animated:YES];
    }];
    editRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    [editRowAction setBackgroundColor:[UIColor blueColor]];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除警告"
                                                                                 message:@"你真的要删除么？这将删除所有相关数据且无法恢复( ˘•ω•˘ ).｡oஇ" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不删了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString * habitName = [self.dataSource[indexPath.row] name];
            [[BEARDatabaseManager share]deleteObj:self.dataSource[indexPath.row]];
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [[BEARDatabaseManager share]saveWithErrorBlock:^(NSError *error) {
                [TSMessage showNotificationWithTitle: [NSString stringWithFormat:@"删除%@",habitName]
                                            subtitle: @"出了点小问题!(´⌒｀。)"
                                                type:TSMessageNotificationTypeMessage];
            } successBlock:^{
                [TSMessage showNotificationWithTitle: [NSString stringWithFormat:@"删除%@",habitName]
                                            subtitle: @"成功删除了(´･_･`)ﾉ"
                                                type:TSMessageNotificationTypeMessage];
                if (self.dataSource.count == 0) {
                    self.emptyView.hidden = NO;
                }
            }];
            [self.habitTable reloadData];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    deleteRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    [deleteRowAction setBackgroundColor:[UIColor grayColor]];
    
    return @[didiRowAction, editRowAction, deleteRowAction];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self jumpToDIDIPageWithIndexPath:indexPath];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - Actions
-(void)jumpToDetailPageWithIndexPath:(NSIndexPath*)indexPath
{
    BEARHabitDetailViewController * detailVC = [[BEARHabitDetailViewController alloc]initWithNibName:@"BEARHabitDetailViewController" bundle:nil withHabitItem:self.dataSource[indexPath.row]];
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)jumpToDIDIPageWithIndexPath:(NSIndexPath*)indexPath
{
    BEARDIDIViewController * didiVC = [[BEARDIDIViewController alloc] initWithHabitItem:self.dataSource[indexPath.row]];
    [self.navigationController pushViewController:didiVC animated:YES];
}


@end
