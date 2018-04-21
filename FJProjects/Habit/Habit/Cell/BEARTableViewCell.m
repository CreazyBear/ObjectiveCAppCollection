//
//  BEARTableViewCell.m
//  Habit
//
//  Created by 熊伟 on 2017/10/24.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARTableViewCell.h"
#import "BEARCheckInProgressView.h"

@interface BEARTableViewCell()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *totalDays;

@property (nonatomic, strong) BEARCheckInProgressView *progressOne;
@property (nonatomic, strong) BEARCheckInProgressView *progressTwo;

@property (nonatomic, strong) UILabel *expectLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation BEARTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews
{
    self.contentView.backgroundColor = BackgroundColor;
    [self setupContainerView];
    [self setupNameLabel];
    [self setupTotalDaysLabel];
    [self setupProgressOne];
    [self setupProgressTwo];
    [self setupExpectLabel];
    [self setupLineViews];
}

-(void)bindData:(BEARHabitItem*)habitItem
{
    self.nameLabel.text = habitItem.name;
    NSMutableSet * dateSet = [NSMutableSet new];
    [habitItem.habitData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, BOOL * _Nonnull stop) {
        [dateSet addObject:obj.date.shortDateString];
    }];
    self.totalDays.text = [NSString stringWithFormat:@"累计 : %ld 天",dateSet.count];

    __block NSInteger todayTotalNumter = 0;
    __block NSInteger todayTotalTime = 0;
    [habitItem.habitData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.date isToday]){
            todayTotalNumter += obj.count;
            todayTotalTime += obj.time;
        }
    }];
    
    if (habitItem.isCounter && habitItem.isTimer) {
        [_progressOne updataInfo:BEARHabitCountTypeTime count:habitItem.expectTime currentData:todayTotalTime];
        [_progressTwo updataInfo:BEARHabitCountTypeNumber count:habitItem.expectCount currentData:todayTotalNumter];
        _progressOne.hidden = NO;
        _progressTwo.hidden = NO;
        self.expectLabel.text = [NSString stringWithFormat:@"今日目标：%lld分钟    %lld 次",habitItem.expectTime,habitItem.expectCount];
        
    }
    else if (habitItem.isCounter && !habitItem.isTimer) {
        [_progressOne updataInfo:BEARHabitCountTypeNumber count:habitItem.expectCount currentData:todayTotalNumter];
        _progressTwo.hidden = YES;
        self.expectLabel.text = [NSString stringWithFormat:@"今日目标：%lld 次",habitItem.expectCount];
    }
    else if (!habitItem.isCounter && habitItem.isTimer) {
        [_progressOne updataInfo:BEARHabitCountTypeTime count:habitItem.expectTime currentData:todayTotalTime];
        _progressTwo.hidden = YES;
        self.expectLabel.text = [NSString stringWithFormat:@"今日目标：%lld分钟",habitItem.expectTime];
    }
}

#pragma mark - lazy views
-(BEARCheckInProgressView *)progressOne
{
    if (!_progressOne) {
        _progressOne = [[BEARCheckInProgressView alloc]initWithCurrentData:0 withExpectData:100 withCountType:(BEARHabitCountTypeTime)];
        _progressOne.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _progressOne;
}

-(BEARCheckInProgressView *)progressTwo
{
    if (!_progressTwo) {
        _progressTwo = [[BEARCheckInProgressView alloc]initWithCurrentData:0 withExpectData:100 withCountType:(BEARHabitCountTypeNumber)];
        _progressTwo.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _progressTwo;
}

-(UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _containerView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLabel;
}

-(UILabel *)totalDays
{
    if (!_totalDays) {
        _totalDays = [[UILabel alloc]init];
        _totalDays.font = [UIFont systemFontOfSize:15];
        _totalDays.textColor = [UIColor blackColor];
        _totalDays.translatesAutoresizingMaskIntoConstraints = NO;
        _totalDays.textAlignment = NSTextAlignmentRight;
    }
    return _totalDays;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor lightGrayColor];
        _lineView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _lineView;
}

-(UILabel *)expectLabel
{
    if (!_expectLabel) {
        _expectLabel = [[UILabel alloc]init];
        _expectLabel.textColor = [UIColor orangeColor];
        _expectLabel.font = [UIFont systemFontOfSize:15];
        _expectLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _expectLabel;
}

-(void)setupExpectLabel
{
    [self.containerView addSubview:self.expectLabel];
    [self.expectLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:20].active = YES;
    [self.expectLabel.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-8].active = YES;
    [self.expectLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:20].active = YES;
}

-(void)setupTotalDaysLabel{
    [self.containerView addSubview:self.totalDays];
    [self.totalDays.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:0].active = YES;
    [self.totalDays.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-20].active = YES;
    [self.totalDays.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:10].active = YES;
}


-(void)setupNameLabel{
    [self.containerView addSubview:self.nameLabel];
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:20].active = YES;
    [self.nameLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:10].active = YES;
    [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-200].active = YES;
}


-(void)setupContainerView
{
    [self.contentView addSubview:self.containerView];
    [self.containerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:5].active = YES;
    [self.containerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    [self.containerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-5].active = YES;
}

-(void)setupProgressOne
{
    [self.containerView addSubview:self.progressOne];
    [self.progressOne.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:20].active = YES;
    [self.progressOne.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:10].active = YES;
    [self.progressOne.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-20].active = YES;
    [self.progressOne.heightAnchor constraintEqualToConstant:40].active = YES;
}

-(void)setupProgressTwo
{
    [self.containerView addSubview:self.progressTwo];
    [self.progressTwo.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:20].active = YES;
    [self.progressTwo.topAnchor constraintEqualToAnchor:self.progressOne.bottomAnchor constant:10].active = YES;
    [self.progressTwo.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-20].active = YES;
    [self.progressTwo.heightAnchor constraintEqualToConstant:40].active = YES;
}
-(void)setupLineViews{
    [self.containerView addSubview:self.lineView];
    [self.lineView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
    [self.lineView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
    [self.lineView.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:5].active = YES;
    [self.lineView.heightAnchor constraintEqualToConstant:0.5].active = YES;
}
@end

