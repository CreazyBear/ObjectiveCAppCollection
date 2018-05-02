//
//  AppDelegate.m
//  FJQRScan
//
//  Created by 熊伟 on 2018/4/30.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "AppDelegate.h"
#import "FJHomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    FJHomeViewController * homeVC = [FJHomeViewController new];
    [self.window setRootViewController:homeVC];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
