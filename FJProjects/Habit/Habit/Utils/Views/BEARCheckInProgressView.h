//
//  BEARCheckInProgressView.h
//  Habit
//
//  Created by 熊伟 on 2017/10/27.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEARCheckInProgressView : UIView
- (instancetype)initWithCurrentData:(NSInteger)currentData
                     withExpectData:(NSInteger)expectData
                      withCountType:(BEARHabitCountType)countType;

-(void)updataInfo:(BEARHabitCountType)type count:(NSInteger)expectData currentData:(NSInteger)currentData;
@end
