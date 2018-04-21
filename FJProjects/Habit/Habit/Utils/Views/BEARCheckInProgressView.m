//
//  BEARCheckInProgressView.m
//  Habit
//
//  Created by 熊伟 on 2017/10/27.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARCheckInProgressView.h"

const NSInteger scaleRate = 3;

@interface BEARCheckInProgressView()

@property (nonatomic, assign) NSInteger currentData;
@property (nonatomic, assign) NSInteger expectData;
@property (nonatomic, assign) BEARHabitCountType countType;

@property (nonatomic, strong) UILabel *countSytleLabel;
@property (nonatomic, strong) UILabel *currentDataLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation BEARCheckInProgressView

- (instancetype)initWithCurrentData:(NSInteger)currentData
                     withExpectData:(NSInteger)expectData
                      withCountType:(BEARHabitCountType)countType
{
    self = [super init];
    if (self) {
        self.currentData = currentData;
        self.expectData = expectData;
        self.countType = countType;
        [self setupViews];
    }
    return self;
}

-(void)updataInfo:(BEARHabitCountType)type count:(NSInteger)expectData currentData:(NSInteger)currentData
{
    if (type == BEARHabitCountTypeTime) {
        _countSytleLabel.text = @"计时";
    }
    else{
        _countSytleLabel.text = @"计数";
    }
    CGFloat progressRate = currentData/(CGFloat)expectData;
    [_progressView setProgress:progressRate animated:YES];
    self.currentDataLabel.text = [NSString stringWithFormat:@"%ld",currentData];
}

-(void)setupViews
{
    _countSytleLabel = [UILabel new];
    _countSytleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _countSytleLabel.font = [UIFont systemFontOfSize:15];
    if (self.countType == BEARHabitCountTypeTime) {
        _countSytleLabel.text = @"计时";
    }
    else{
        _countSytleLabel.text = @"计数";
    }
    [self addSubview:_countSytleLabel];
    [self.countSytleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.countSytleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.countSytleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-40].active = YES;
    
    _currentDataLabel = [UILabel new];
    _currentDataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _currentDataLabel.font = [UIFont systemFontOfSize:15];
    _currentDataLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_currentDataLabel];
    [self.currentDataLabel.centerYAnchor constraintEqualToAnchor:self.countSytleLabel.centerYAnchor].active = YES;
    [self.currentDataLabel.leadingAnchor constraintEqualToAnchor:self.countSytleLabel.trailingAnchor].active = YES;
    [self.currentDataLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    
    _progressView = [[UIProgressView alloc]init];
    _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, scaleRate);
    _progressView.transform = transform;//设定宽高
    _progressView.trackTintColor = [UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1];
    _progressView.tintColor = [UIColor colorWithRed:70/255.f green:137/255.f blue:106/255.f alpha:1];
    
    [self addSubview:_progressView];
    [self.progressView.topAnchor constraintEqualToAnchor:self.countSytleLabel.bottomAnchor constant:10].active = YES;
    [self.progressView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.progressView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.progressView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;;
    
}


@end
