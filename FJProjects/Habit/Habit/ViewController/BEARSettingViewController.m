//
//  BEARSettingViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/11/3.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARSettingViewController.h"
#import <MessageUI/MessageUI.h>

@interface BEARSettingViewController ()
@property (weak, nonatomic) IBOutlet UIView *appStoreView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *versionView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIView *feedBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation BEARSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBorder:self.aboutView];
    [self setupBorder:self.appStoreView];
    [self setupBorder:self.feedBackView];
    [self setupBorder:self.versionView];
    self.topConstraint.constant += SafeAreaTopHeight;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号:%@",appVersion];
    
    self.appStoreView.hidden = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToAppStore)];
    [self.appStoreView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer * feedBackGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onFeedbackViewClicked)];
    [self.feedBackView addGestureRecognizer:feedBackGesture];
    
}

-(void)onFeedbackViewClicked
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"意见反馈"
                                                                             message:@"你可以直接将问题反馈到我的QQ:597370561~(๑◔‿◔๑)" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setupBorder:(UIView*)view
{
    view.layer.cornerRadius = 2;
    view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)goToAppStore
{
//    NSString *str = [NSString stringWithFormat:
//                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",0];
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
//    }
    
}
@end
