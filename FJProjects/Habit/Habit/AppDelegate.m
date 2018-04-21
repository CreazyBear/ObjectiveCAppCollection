//
//  AppDelegate.m
//  Habit
//
//  Created by 熊伟 on 2017/10/17.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "AppDelegate.h"
#import "BEARTodayHabitViewController.h"
#import "BEARTabBarController.h"
#import "BEARNavigationViewController.h"
#import "BEARTodayHabitViewController.h"
#import "BEARNewHabitViewController.h"
#import "BEARHabitCalendarViewController.h"
#import "BEARMineViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) BEARTabBarController *rootTabCtrl;
@property (nonatomic, strong) BEARTodayHabitViewController * todayHabitVC;
@property (nonatomic, strong) BEARHabitCalendarViewController * habitCalendarVC;
@property (nonatomic, strong) BEARMineViewController * mineHabitVC;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    _todayHabitVC = [[BEARTodayHabitViewController alloc]init];
    _todayHabitVC.title = @"今时";
    [_todayHabitVC.tabBarItem setImage:[UIImage imageNamed:@"clock"]];
    BEARNavigationViewController * todayHabitNav = [[BEARNavigationViewController alloc]initWithRootViewController: _todayHabitVC];
    
    _habitCalendarVC = [[BEARHabitCalendarViewController alloc]init];
    _habitCalendarVC.title = @"往日";
    [_habitCalendarVC.tabBarItem setImage:[UIImage imageNamed:@"calendar"]];
    BEARNavigationViewController * habitCalendarNav = [[BEARNavigationViewController alloc]initWithRootViewController:_habitCalendarVC];
    
    _mineHabitVC = [[BEARMineViewController alloc]init];
    _mineHabitVC.title = @"我的";
    [_mineHabitVC.tabBarItem setImage:[UIImage imageNamed:@"trophy"]];
    BEARNavigationViewController * mineNav = [[BEARNavigationViewController alloc]initWithRootViewController:_mineHabitVC];
    
    _rootTabCtrl = [[BEARTabBarController alloc]init];
    _rootTabCtrl.viewControllers = @[todayHabitNav,habitCalendarNav,mineNav];
    self.window.rootViewController = _rootTabCtrl;
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //TODO: NOTIFICAITON INFO
    NSDictionary * userInfo = notification.userInfo;
    [TSMessage showNotificationWithTitle: [userInfo valueForKey:@"title"]
                                subtitle: [userInfo valueForKey:@"body"]
                                    type:TSMessageNotificationTypeMessage];
}




@end
