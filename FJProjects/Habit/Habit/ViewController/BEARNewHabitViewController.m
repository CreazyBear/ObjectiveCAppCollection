//
//  BEARNewHabitViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/10/17.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARNewHabitViewController.h"

@interface BEARNewHabitViewController ()<UITextFieldDelegate>
@property (nonatomic, assign) CGFloat containerViewMarging;
@property (nonatomic, assign) CGFloat containerViewPaddingHorizontal;
@property (nonatomic, assign) CGFloat containerViewPaddingVertical;
@property (nonatomic, assign) CGFloat containerSubViewLineSpace;

@property (nonatomic, assign) BOOL keyboardVisiable;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) UIView *nameContainer;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) BEARTextField *nameText;

@property (nonatomic, strong) UIView *notifyContainer;
@property (nonatomic, strong) UILabel *notifyLabel;
@property (nonatomic, strong) UISwitch *notifySwitch;
@property (nonatomic, strong) UIDatePicker *notifyDatePicker;
@property (nonatomic, strong) UIView *notifyMaskView;

@property (nonatomic, strong) UIView *endDateContainer;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UISwitch *endDateSwitch;
@property (nonatomic, strong) UIDatePicker *endDateDatePicker;
@property (nonatomic, strong) UIView *endDateMaskView;

@property (nonatomic, strong) UIView *countStyleContainer;
@property (nonatomic, strong) UILabel *countStyleLabel;
@property (nonatomic, strong) UILabel *countNumberLabel;
@property (nonatomic, strong) UISwitch *countNumberSwitch;
@property (nonatomic, strong) UIView *seperateLine;
@property (nonatomic, strong) BEARTextField *expectCountText;

@property (nonatomic, strong) UILabel *countTimeLabel;
@property (nonatomic, strong) UISwitch *countTimeSwitch;
@property (nonatomic, strong) BEARTextField *expectTimeText;

@property (nonatomic, assign) BOOL isModify;
@property (nonatomic, strong) BEARHabitItem *habitItem;
@property (nonatomic, strong) NSArray <BEARHabitItem*>* existHabits;

@end

@implementation BEARNewHabitViewController
- (instancetype)initWithModify:(BEARHabitItem*)habitItem
{
    self = [super init];
    if (self) {
        self.isModify = YES;
        self.habitItem = habitItem;
    }
    return self;
}

- (instancetype)initWithExistHabits:(NSArray<BEARHabitItem*>*)habits
{
    self = [super init];
    if (self) {
        self.existHabits = habits;
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isModify = NO;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    //注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    //解除键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    //解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupConst];
    [self setupNavRightButton];
    [self.view setBackgroundColor:BackgroundColor];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBackGroundViewTaped:)];
    [self.view addGestureRecognizer:tapGesture];
    [self setupViews];
    if (_isModify) {
        _nameText.text = _habitItem.name;
        if (_habitItem.isNotify) {
            [self.notifySwitch setOn:YES];
            self.notifyDatePicker.date = self.habitItem.notifyTime;
            self.notifyMaskView.hidden = YES;
        }
        if (self.habitItem.isHasEnd) {
            [self.endDateSwitch setOn:YES];
            self.endDateDatePicker.date = self.habitItem.endTime;
            self.endDateMaskView.hidden = YES;
        }
        if (self.habitItem.isCounter) {
            [self.countNumberSwitch setOn:YES];
            self.expectCountText.text = [NSString stringWithFormat:@"%lld",self.habitItem.expectCount];
            [self.expectCountText setEnabled:YES];
            self.expectCountText.userInteractionEnabled = YES;
        }
        if (self.habitItem.isTimer) {
            [self.countTimeSwitch setOn:YES];
            self.expectTimeText.text = [NSString stringWithFormat:@"%lld",self.habitItem.expectTime];
            [self.expectTimeText setEnabled:YES];
            self.expectTimeText.userInteractionEnabled = YES;
        }
    }
}

-(void)setupConst
{
    self.title = @"新的征程";
    self.containerViewMarging = 20;
    self.containerViewPaddingHorizontal = 20;
    self.containerViewPaddingVertical = 15;
    self.containerSubViewLineSpace = 10;
}

-(void)onBackGroundViewTaped:(UITapGestureRecognizer*)gesture
{
    [self endEditText];
}

-(void)endEditText{
    [self.nameText resignFirstResponder];
    [self.expectCountText resignFirstResponder];
    [self.expectTimeText resignFirstResponder];
}

-(void)setupViews
{
    [self setupContentScrollView];
    
    [self setupNameContainer];
    [self setupNameLabel];
    [self setupNameText];

    [self setupNotifyContainer];
    [self setupNotifyLabel];
    [self setupNotifySwitch];
    [self setupNotifyDatePicker];
    [self setupNotifyMaskView];
    
    [self setupEndDateContainer];
    [self setupEndDateLabel];
    [self setupEndDateSwitch];
    [self setupEndDateDatePicker];
    [self setupEndDateMaskView];

    [self setupCountStyleContainer];
    [self setupCountStyleLabel];
    [self setupCountNumberLabel];
    [self setupCountNumbserSwitch];
    [self setupSeperateLine];
    [self setupExpectCountText];
    [self setupCountTimeLabel];
    [self setupCountTimeSwitch];
    [self setupExpectTimeText];
    
    
}

#pragma mark - common setup
-(void)setupContainerView:(UIView*)view
{
    view.backgroundColor = [UIColor whiteColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.layer.shadowOffset = CGSizeMake(1, 2);
    view.layer.shadowRadius = 2;
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOpacity = 0.8;
    view.layer.cornerRadius = 4;
    [self.contentScrollView addSubview:view];

}

#pragma mark - scrollView
-(UIScrollView *)contentScrollView
{
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc]init];
        _contentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentScrollView setBackgroundColor:BackgroundColor];
    }
    return _contentScrollView;
}

-(void)setupContentScrollView
{
    [self.view addSubview:self.contentScrollView];
    [self.contentScrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.contentScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.contentScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    self.bottomConstraint = [self.contentScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.bottomConstraint.active = YES;
}

#pragma mark - count style
-(BEARTextField *)expectCountText
{
    if (!_expectCountText) {
        _expectCountText = [BEARTextField new];
        _expectCountText.placeholder = @"期望值/次";
        _expectCountText.textColor = [UIColor blackColor];
        _expectCountText.font = [UIFont systemFontOfSize:16];
        _expectCountText.translatesAutoresizingMaskIntoConstraints = NO;
        _expectCountText.delegate = self;
        _expectCountText.layer.cornerRadius = 4;
        _expectCountText.layer.borderWidth = 1;
        _expectCountText.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_expectCountText setPaddingLeft:10 right:0 top:0 bottom:0];
        [_expectCountText setKeyboardType:(UIKeyboardTypeNumberPad)];
        [self.expectCountText setUserInteractionEnabled:NO];
    }
    return _expectCountText;
}

-(void)setupExpectCountText
{
    [self.countStyleContainer addSubview:self.expectCountText];
    [self.expectCountText.leadingAnchor constraintEqualToAnchor:self.countStyleContainer.leadingAnchor constant:_containerViewPaddingHorizontal].active = YES;
    [self.expectCountText.topAnchor constraintEqualToAnchor:self.countNumberLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.expectCountText.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.trailingAnchor constant:-_containerViewPaddingHorizontal].active = YES;
    [self.expectCountText.heightAnchor constraintEqualToConstant:30].active = YES;
    
}

-(BEARTextField *)expectTimeText
{
    if (!_expectTimeText) {
        _expectTimeText = [BEARTextField new];
        _expectTimeText.placeholder = @"期望值/分钟";
        _expectTimeText.textColor = [UIColor blackColor];
        _expectTimeText.font = [UIFont systemFontOfSize:16];
        _expectTimeText.translatesAutoresizingMaskIntoConstraints = NO;
        _expectTimeText.delegate = self;
        _expectTimeText.layer.cornerRadius = 4;
        _expectTimeText.layer.borderWidth = 1;
        _expectTimeText.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_expectTimeText setPaddingLeft:10 right:0 top:0 bottom:0];
        [self.expectTimeText setUserInteractionEnabled:NO];
        [_expectTimeText setKeyboardType:(UIKeyboardTypeNumberPad)];
    }
    return _expectTimeText;
}

-(void)setupExpectTimeText
{
    [self.countStyleContainer addSubview:self.expectTimeText];
    [self.expectTimeText.leadingAnchor constraintEqualToAnchor:self.countStyleContainer.leadingAnchor constant:_containerViewPaddingHorizontal].active = YES;
    [self.expectTimeText.topAnchor constraintEqualToAnchor:self.countTimeLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.expectTimeText.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.trailingAnchor constant:-_containerViewPaddingHorizontal].active = YES;
    [self.expectTimeText.heightAnchor constraintEqualToConstant:30].active = YES;
    
}



-(UIView *)countStyleContainer
{
    if (!_countStyleContainer) {
        _countStyleContainer = [UIView new];
        [self setupContainerView:_countStyleContainer];
    }
    return _countStyleContainer;
}

-(void)setupCountStyleContainer
{
    [self.countStyleContainer.topAnchor constraintEqualToAnchor:self.endDateContainer.bottomAnchor constant:_containerViewMarging].active = YES;
    [self.countStyleContainer.leadingAnchor constraintEqualToAnchor:self.countStyleContainer.superview.leadingAnchor constant:_containerViewMarging].active = YES;
    [self.countStyleContainer.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.superview.trailingAnchor constant:-_containerViewMarging].active = YES;
    [self.countStyleContainer.widthAnchor constraintEqualToConstant:SCREEN_WIDTH-2*_containerViewMarging].active = YES;
    [self.countStyleContainer.heightAnchor constraintEqualToConstant:230].active = YES;
    [self.countStyleContainer.bottomAnchor constraintEqualToAnchor:self.countStyleContainer.superview.bottomAnchor constant:-30].active = YES;
}

-(UILabel *)countStyleLabel{
    if (!_countStyleLabel) {
        _countStyleLabel = [[UILabel alloc]init];
        _countStyleLabel.text = @"统计方式";
        _countStyleLabel.textColor = [UIColor blackColor];
        _countStyleLabel.font = [UIFont systemFontOfSize:16];
        _countStyleLabel.numberOfLines = 1;
        _countStyleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _countStyleLabel;
}

-(void)setupCountStyleLabel{
    [self.countStyleContainer addSubview:self.countStyleLabel];
    [self.countStyleLabel.topAnchor constraintEqualToAnchor:self.countStyleLabel.superview.topAnchor constant: self.containerViewPaddingVertical].active = YES;
    [self.countStyleLabel.leadingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.countStyleLabel.trailingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}

-(UILabel *)countNumberLabel
{
    if (!_countNumberLabel) {
        _countNumberLabel = [[UILabel alloc]init];
        _countNumberLabel.text = @"计数";
        _countNumberLabel.textColor = [UIColor blackColor];
        _countNumberLabel.font = [UIFont systemFontOfSize:16];
        _countNumberLabel.numberOfLines = 1;
        _countNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _countNumberLabel;
}

-(void)setupCountNumberLabel
{
    [self.countStyleContainer addSubview:self.countNumberLabel];
    [self.countNumberLabel.topAnchor constraintEqualToAnchor:self.countStyleLabel.bottomAnchor constant: 2*self.containerSubViewLineSpace].active = YES;
    [self.countNumberLabel.leadingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.countNumberLabel.trailingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;

}

-(UIView *)seperateLine
{
    if (!_seperateLine) {
        _seperateLine = [UIView new];
        _seperateLine.translatesAutoresizingMaskIntoConstraints = NO;
        _seperateLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _seperateLine;
}

-(void)setupSeperateLine
{
    [self.countStyleContainer addSubview:self.seperateLine];
    [self.seperateLine.topAnchor constraintEqualToAnchor:self.countStyleLabel.bottomAnchor constant:10].active = YES;
    [self.seperateLine.leadingAnchor constraintEqualToAnchor:self.countStyleContainer.leadingAnchor].active = YES;
    [self.seperateLine.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.trailingAnchor].active = YES;
    [self.seperateLine.heightAnchor constraintEqualToConstant:0.5].active = YES;
}

-(UISwitch *)countNumberSwitch
{
    if (!_countNumberSwitch) {
        _countNumberSwitch = [UISwitch new];
        _countNumberSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [_countNumberSwitch setOn:NO];
        [_countNumberSwitch addTarget:self action:@selector(countNumberSwitchAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _countNumberSwitch;
}

-(void)countNumberSwitchAction:(UISwitch*)sender
{
    [self.expectCountText setEnabled: [sender isOn]];
    [self.expectCountText setUserInteractionEnabled:[sender isOn]];
    if ([sender isOn]) {
        [self.expectCountText becomeFirstResponder];
    }
    else{
        [self.expectCountText setText:@""];
    }
    [self endEditText];
}

-(void)setupCountNumbserSwitch
{
    [self.countStyleContainer addSubview:self.countNumberSwitch];
    [self.countNumberSwitch.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.trailingAnchor constant:-_containerViewPaddingHorizontal].active = YES;
    [self.countNumberSwitch.centerYAnchor constraintEqualToAnchor:self.countNumberLabel.centerYAnchor].active = YES;
}

-(UILabel *)countTimeLabel
{
    if (!_countTimeLabel) {
        _countTimeLabel = [[UILabel alloc]init];
        _countTimeLabel.text = @"计时";
        _countTimeLabel.textColor = [UIColor blackColor];
        _countTimeLabel.font = [UIFont systemFontOfSize:16];
        _countTimeLabel.numberOfLines = 1;
        _countTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _countTimeLabel;
}

-(void)setupCountTimeLabel
{
    [self.countStyleContainer addSubview:self.countTimeLabel];
    [self.countTimeLabel.topAnchor constraintEqualToAnchor:self.expectCountText.bottomAnchor constant: 2*self.containerSubViewLineSpace].active = YES;
    [self.countTimeLabel.leadingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.countTimeLabel.trailingAnchor constraintEqualToAnchor:self.countStyleLabel.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
    
}

-(UISwitch *)countTimeSwitch
{
    if (!_countTimeSwitch) {
        _countTimeSwitch = [UISwitch new];
        _countTimeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [_countTimeSwitch setOn:NO];
        [_countTimeSwitch addTarget:self action:@selector(countTimeSwitchAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _countTimeSwitch;
}

-(void)countTimeSwitchAction:(UISwitch*)sender
{
    [self.expectTimeText setEnabled: [sender isOn]];
    [self.expectTimeText setUserInteractionEnabled:[sender isOn]];
    if ([sender isOn]) {
        [self.expectTimeText becomeFirstResponder];
    }
    else{
        [self.expectTimeText setText:@""];
    }
    [self endEditText];
}

-(void)setupCountTimeSwitch
{
    [self.countStyleContainer addSubview:self.countTimeSwitch];
    [self.countTimeSwitch.trailingAnchor constraintEqualToAnchor:self.countStyleContainer.trailingAnchor constant:-_containerViewPaddingHorizontal].active = YES;
    [self.countTimeSwitch.centerYAnchor constraintEqualToAnchor:self.countTimeLabel.centerYAnchor].active = YES;
}

#pragma mark - endDate
-(UIView *)endDateContainer
{
    if (!_endDateContainer) {
        _endDateContainer = [UIView new];
        [self setupContainerView:_endDateContainer];
    }
    return _endDateContainer;
}

-(void)setupEndDateContainer
{
    [self.endDateContainer.topAnchor constraintEqualToAnchor:self.notifyContainer.bottomAnchor constant:_containerViewMarging].active = YES;
    [self.endDateContainer.leadingAnchor constraintEqualToAnchor:self.endDateContainer.superview.leadingAnchor constant:_containerViewMarging].active = YES;
    [self.endDateContainer.trailingAnchor constraintEqualToAnchor:self.endDateContainer.superview.trailingAnchor constant:-_containerViewMarging].active = YES;
    [self.endDateContainer.widthAnchor constraintEqualToConstant:SCREEN_WIDTH-2*_containerViewMarging].active = YES;
    [self.endDateContainer.heightAnchor constraintEqualToConstant:300].active = YES;
}

-(UILabel *)endDateLabel{
    if (!_endDateLabel) {
        _endDateLabel = [[UILabel alloc]init];
        _endDateLabel.text = @"结束日期";
        _endDateLabel.textColor = [UIColor blackColor];
        _endDateLabel.font = [UIFont systemFontOfSize:16];
        _endDateLabel.numberOfLines = 1;
        _endDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _endDateLabel;
}

-(void)setupEndDateLabel{
    [self.endDateContainer addSubview:self.endDateLabel];
    [self.endDateLabel.topAnchor constraintEqualToAnchor:self.endDateLabel.superview.topAnchor constant: self.containerViewPaddingVertical].active = YES;
    [self.endDateLabel.leadingAnchor constraintEqualToAnchor:self.endDateLabel.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.endDateLabel.trailingAnchor constraintEqualToAnchor:self.endDateLabel.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}

-(UISwitch *)endDateSwitch
{
    if (!_endDateSwitch) {
        _endDateSwitch = [UISwitch new];
        _endDateSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [_endDateSwitch setOn:NO];
        [_endDateSwitch addTarget:self action:@selector(endDateSwitchAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _endDateSwitch;
}

-(void)endDateSwitchAction:(UISwitch*)sender
{
    BOOL isButtonOn = [sender isOn];
    if (isButtonOn) {
        self.endDateDatePicker.userInteractionEnabled = YES;
        self.endDateMaskView.hidden = YES;
    }
    else{
        self.endDateDatePicker.userInteractionEnabled = NO;
        self.endDateMaskView.hidden = NO;
    }
    [self endEditText];
}

-(void)setupEndDateSwitch
{
    [self.endDateContainer addSubview:self.endDateSwitch];
    [self.endDateSwitch.centerYAnchor constraintEqualToAnchor:self.endDateLabel.centerYAnchor].active = YES;
    [self.endDateSwitch.trailingAnchor constraintEqualToAnchor:self.endDateContainer.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}

-(UIView *)endDateMaskView
{
    if (!_endDateMaskView) {
        _endDateMaskView = [UIView new];
        _endDateMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        _endDateMaskView.backgroundColor = [UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:0.6];
        _endDateMaskView.hidden = NO;
    }
    return _endDateMaskView;
}

-(void)setupEndDateMaskView{
    [self.endDateContainer addSubview:self.endDateMaskView];
    [self.endDateMaskView.topAnchor constraintEqualToAnchor:self.endDateLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.endDateMaskView.leadingAnchor constraintEqualToAnchor:self.endDateContainer.leadingAnchor].active = YES;
    [self.endDateMaskView.trailingAnchor constraintEqualToAnchor:self.endDateContainer.trailingAnchor].active = YES;
    [self.endDateMaskView.bottomAnchor constraintEqualToAnchor:self.endDateContainer.bottomAnchor].active = YES;
}



-(UIDatePicker *)endDateDatePicker
{
    if (!_endDateDatePicker) {
        _endDateDatePicker = [UIDatePicker new];
        _endDateDatePicker.minimumDate = [NSDate new];
        _endDateDatePicker.datePickerMode = UIDatePickerModeDate;
        _endDateDatePicker.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _endDateDatePicker;
}

-(void)setupEndDateDatePicker
{
    [self.endDateContainer addSubview:self.endDateDatePicker];
    [self.endDateDatePicker.topAnchor constraintEqualToAnchor:self.endDateLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.endDateDatePicker.centerXAnchor constraintEqualToAnchor:self.endDateContainer.centerXAnchor].active = YES;
    [self.endDateDatePicker.bottomAnchor constraintEqualToAnchor:self.endDateContainer.bottomAnchor constant:-_containerViewPaddingVertical].active = YES;
}

#pragma mark - notify
-(UIView *)notifyMaskView
{
    if (!_notifyMaskView) {
        _notifyMaskView = [UIView new];
        _notifyMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        _notifyMaskView.backgroundColor = [UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:0.6];
        _notifyMaskView.hidden = NO;
    }
    return _notifyMaskView;
}

-(void)setupNotifyMaskView{
    [self.notifyContainer addSubview:self.notifyMaskView];
    [self.notifyMaskView.topAnchor constraintEqualToAnchor:self.notifyLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.notifyMaskView.leadingAnchor constraintEqualToAnchor:self.notifyContainer.leadingAnchor].active = YES;
    [self.notifyMaskView.trailingAnchor constraintEqualToAnchor:self.notifyContainer.trailingAnchor].active = YES;
    [self.notifyMaskView.bottomAnchor constraintEqualToAnchor:self.notifyContainer.bottomAnchor].active = YES;
}



-(UIDatePicker *)notifyDatePicker
{
    if (!_notifyDatePicker) {
        _notifyDatePicker = [UIDatePicker new];
        _notifyDatePicker.datePickerMode = UIDatePickerModeTime;
        _notifyDatePicker.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _notifyDatePicker;
}

-(void)setupNotifyDatePicker
{
    [self.notifyContainer addSubview:self.notifyDatePicker];
    [self.notifyDatePicker.topAnchor constraintEqualToAnchor:self.notifyLabel.bottomAnchor constant:_containerSubViewLineSpace].active = YES;
    [self.notifyDatePicker.centerXAnchor constraintEqualToAnchor:self.notifyContainer.centerXAnchor].active = YES;
    [self.notifyDatePicker.bottomAnchor constraintEqualToAnchor:self.notifyContainer.bottomAnchor constant:-_containerViewPaddingVertical].active = YES;
}

-(UIView *)notifyContainer
{
    if (!_notifyContainer) {
        _notifyContainer = [UIView new];
        [self setupContainerView:_notifyContainer];
    }
    return _notifyContainer;
}

-(void)setupNotifyContainer
{
    [self.notifyContainer.topAnchor constraintEqualToAnchor:self.nameContainer.bottomAnchor constant:_containerViewMarging].active = YES;
    [self.notifyContainer.leadingAnchor constraintEqualToAnchor:self.notifyContainer.superview.leadingAnchor constant:_containerViewMarging].active = YES;
    [self.notifyContainer.trailingAnchor constraintEqualToAnchor:self.notifyContainer.superview.trailingAnchor constant:-_containerViewMarging].active = YES;
    [self.notifyContainer.widthAnchor constraintEqualToConstant:SCREEN_WIDTH-2*_containerViewMarging].active = YES;
    [self.notifyContainer.heightAnchor constraintEqualToConstant:300].active = YES;

}

-(UILabel *)notifyLabel{
    if (!_notifyLabel) {
        _notifyLabel = [[UILabel alloc]init];
        _notifyLabel.text = @"提醒";
        _notifyLabel.textColor = [UIColor blackColor];
        _notifyLabel.font = [UIFont systemFontOfSize:16];
        _notifyLabel.numberOfLines = 1;
        _notifyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _notifyLabel;
}

-(void)setupNotifyLabel{
    [self.notifyContainer addSubview:self.notifyLabel];
    [self.notifyLabel.topAnchor constraintEqualToAnchor:self.notifyLabel.superview.topAnchor constant: self.containerViewPaddingVertical].active = YES;
    [self.notifyLabel.leadingAnchor constraintEqualToAnchor:self.notifyLabel.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.notifyLabel.trailingAnchor constraintEqualToAnchor:self.notifyLabel.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}

-(UISwitch *)notifySwitch
{
    if (!_notifySwitch) {
        _notifySwitch = [UISwitch new];
        _notifySwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [_notifySwitch setOn:NO];
        [_notifySwitch addTarget:self action:@selector(notifySwitchAction:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _notifySwitch;
}

-(void)notifySwitchAction:(UISwitch*)sender
{
    BOOL isButtonOn = [sender isOn];
    if (isButtonOn) {
        self.notifyDatePicker.userInteractionEnabled = YES;
        self.notifyMaskView.hidden = YES;
    }
    else{
        self.notifyDatePicker.userInteractionEnabled = NO;
        self.notifyMaskView.hidden = NO;
    }
    [self endEditText];
}

-(void)setupNotifySwitch
{
    [self.notifyContainer addSubview:self.notifySwitch];
    [self.notifySwitch.centerYAnchor constraintEqualToAnchor:self.notifyLabel.centerYAnchor].active = YES;
    [self.notifySwitch.trailingAnchor constraintEqualToAnchor:self.notifyContainer.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}


#pragma mark - name
-(UIView *)nameContainer
{
    if (!_nameContainer) {
        _nameContainer = [UIView new];
        [self setupContainerView:_nameContainer];
    }
    return _nameContainer;
}

-(void)setupNameContainer
{
    [self.nameContainer.topAnchor constraintEqualToAnchor:self.nameContainer.superview.topAnchor constant:_containerViewMarging].active = YES;
    [self.nameContainer.leadingAnchor constraintEqualToAnchor:self.nameContainer.superview.leadingAnchor constant:_containerViewMarging].active = YES;
    [self.nameContainer.trailingAnchor constraintEqualToAnchor:self.nameContainer.superview.trailingAnchor constant:-_containerViewMarging].active = YES;
    [self.nameContainer.widthAnchor constraintEqualToConstant:SCREEN_WIDTH-_containerViewMarging*2].active = YES;
    [self.nameContainer.heightAnchor constraintEqualToConstant:90].active = YES;
}

-(UILabel *)nameLable{
    if (!_nameLable) {
        _nameLable = [[UILabel alloc]init];
        _nameLable.text = @"名称";
        _nameLable.textColor = [UIColor blackColor];
        _nameLable.font = [UIFont systemFontOfSize:16];
        _nameLable.numberOfLines = 1;
        _nameLable.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLable;
}

-(void)setupNameLabel{
    [self.nameContainer addSubview:self.nameLable];
    [self.nameLable.topAnchor constraintEqualToAnchor:self.nameLable.superview.topAnchor constant: self.containerViewPaddingVertical].active = YES;
    [self.nameLable.leadingAnchor constraintEqualToAnchor:self.nameLable.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.nameLable.trailingAnchor constraintEqualToAnchor:self.nameLable.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
}

-(BEARTextField *)nameText{
    if (!_nameText) {
        _nameText = [[BEARTextField alloc]init];
        _nameText.textColor = [UIColor blackColor];
        _nameText.font = [UIFont systemFontOfSize:16];
        _nameText.placeholder = @" 起个响亮的名字";
        _nameText.translatesAutoresizingMaskIntoConstraints = NO;
        _nameText.delegate = self;
        _nameText.layer.cornerRadius = 4;
        _nameText.layer.borderWidth = 1;
        _nameText.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_nameText setPaddingLeft:10 right:0 top:0 bottom:0];
    }
    return _nameText;
}

-(void)setupNameText
{
    [self.nameContainer addSubview:self.nameText];
    [self.nameText.topAnchor constraintEqualToAnchor:self.nameLable.bottomAnchor constant:self.containerSubViewLineSpace].active = YES;
    [self.nameText.leadingAnchor constraintEqualToAnchor:self.nameText.superview.leadingAnchor constant:self.containerViewPaddingHorizontal].active = YES;
    [self.nameText.trailingAnchor constraintEqualToAnchor:self.nameText.superview.trailingAnchor constant:-self.containerViewPaddingHorizontal].active = YES;
    [self.nameText.heightAnchor constraintEqualToConstant:30].active = YES;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor greenColor].CGColor;
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - keyboard
- (void) keyboardWillShow:(NSNotification *) notif
{
    if(_keyboardVisiable)
    {
        return;
    }
    
    // 获得键盘尺寸
    NSDictionary *info = notif.userInfo;
    
    NSValue *aValue = [info objectForKeyedSubscript:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    if ([self.expectCountText isFirstResponder] || [self.expectTimeText isFirstResponder]) {
        self.contentScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        //获取当前文本框架大小
        CGPoint textFieldPoint = CGPointZero;
        textFieldPoint = [self.countStyleContainer frame].origin;
        //滚动到当前文本框
        CGPoint point = CGPointMake(0, textFieldPoint.y - SafeAreaTopHeight - 60);
        [self.contentScrollView setContentOffset:point];
    }
    _keyboardVisiable = YES;
    
}

- (void) keyboardWillHide:(NSNotification *) notif
{
    CGFloat duration = [[notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0.0f options:(curve<<16) animations:^{
        self.contentScrollView.contentInset = UIEdgeInsetsZero;
    } completion:nil];

    if (!_keyboardVisiable) {
        return;
    }
    _keyboardVisiable = NO;
}

#pragma mark - navigation
-(void)setupNavRightButton
{
    UIBarButtonItem * rightBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"保存"
                                                                     style:(UIBarButtonItemStylePlain)
                                                                    target:self
                                                                    action:@selector(onEndEdit)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)onEndEdit{

    NSString * habitName = _nameText.text;
    if ([habitName isNilOrEmpty]) {
        self.nameText.layer.borderColor = [UIColor redColor].CGColor;
        [self.contentScrollView setContentOffset:CGPointZero];
        return;
    }
    
    if ([self isHabitNameExist:_nameText.text]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"习惯名称重复啦"
                                                                                 message:@"((´థ v థ`*))"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             self.nameText.layer.borderColor = [UIColor redColor].CGColor;
                                                             [self.contentScrollView setContentOffset:CGPointZero];
                                                         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    
    BOOL isNotifyOpen = [self.notifySwitch isOn];
    NSDate * notifyDate;
    if (isNotifyOpen) {
        notifyDate = [self.notifyDatePicker date];
    }
    
    BOOL isHasEndTime = [self.endDateSwitch isOn];
    NSDate * endTimeDate;
    if (isHasEndTime) {
        endTimeDate = [self.endDateDatePicker date];
    }
    
    BOOL isCountNum = [self.countNumberSwitch isOn];
    NSString * expectNumStr;
    NSInteger expectNumNum = 0;
    if (isCountNum) {
        expectNumStr = [self.expectCountText text];
        expectNumNum = [expectNumStr integerValue];
    }
    if (isCountNum && expectNumNum <=0) {
        self.expectCountText.layer.borderColor = [UIColor redColor].CGColor;
        [self.contentScrollView scrollRectToVisible:self.countStyleContainer.frame animated:YES];
        return;
    }
    
    BOOL isCountTime = [self.countTimeSwitch isOn];
    NSString * expectTimeStr;
    NSInteger expectTimeNum = 0;
    if (isCountTime) {
        expectTimeStr = [self.expectTimeText text];
        expectTimeNum = [expectTimeStr integerValue];
    }
    if (isCountTime && expectTimeNum <=0) {
        self.expectTimeText.layer.borderColor = [UIColor redColor].CGColor;
        [self.contentScrollView scrollRectToVisible:self.countStyleContainer.frame animated:YES];
        return;
    }
    
    if (!isCountNum && !isCountTime ) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"完善信息提醒"
                                                                                 message:@"亲，计时或者计数需要至少选一个\r\n( ´･ᴗ･` )"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self endEditText];
            [self.contentScrollView scrollRectToVisible:self.countStyleContainer.frame animated:YES];
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    
    BEARHabitItem * habitItem;
    if (_isModify) {
        habitItem = self.habitItem;
    }
    else{
        habitItem = [[BEARDatabaseManager share] newHabitItem];
    }
    habitItem.name = habitName;
    habitItem.isNotify = isNotifyOpen;
    habitItem.notifyTime = notifyDate?notifyDate:nil;
    habitItem.isHasEnd = isHasEndTime;
    habitItem.endTime = endTimeDate?endTimeDate:nil;
    habitItem.isCounter = isCountNum;
    habitItem.expectCount = expectNumNum;
    habitItem.isTimer = isCountTime;
    habitItem.expectTime = expectTimeNum;
    
    [[BEARDatabaseManager share]saveWithErrorBlock:^(NSError *error) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
    } successBlock:^{
#ifdef DEBUG
        NSLog(@"save new habit to database success");
#endif
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(BOOL)isHabitNameExist:(NSString*)habitName
{
    __block BOOL isExist = NO;
    [self.existHabits enumerateObjectsUsingBlock:^(BEARHabitItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:habitName]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}


#pragma mark - debug
-(void)dataBaseTest
{
    BEARHabitItem * habitItem = [[BEARDatabaseManager share] newHabitItem];
    habitItem.name = @"TestOne";
    BEARHabitData * habitData = [[BEARDatabaseManager share] newHabitData];
    habitData.time = 333;
    [habitItem addHabitDataObject:habitData];
    [[BEARDatabaseManager share]saveWithErrorBlock:^(NSError *error) {
        
    } successBlock:^{
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[BEARDatabaseManager share] readEntity:habitItemEntityName
                                   sequenceKeys:nil
                                      ascending:YES
                                      filterPredicate:nil
                                        success:^(NSArray *results) {
                                            
                                            [results enumerateObjectsUsingBlock:^(id  _Nonnull habitObj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                NSSet<BEARHabitData * > *habitData =((BEARHabitItem*)habitObj).habitData;
                                                [habitData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull dataObj, BOOL * _Nonnull stop) {
                                                    NSLog(@"%lld",dataObj.time);
                                                }];
                                            }];
                                        } fail:^(NSError *error) {
                                            
                                        }];
    });
}


@end
