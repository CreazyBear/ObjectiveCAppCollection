//
//  ViewController.m
//  ReactiveObjeCDemo
//
//  Created by 熊伟 on 2018/4/21.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "ViewController.h"
#import <libextobjc/extobjc.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        NSLog(@"%@",self);
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
