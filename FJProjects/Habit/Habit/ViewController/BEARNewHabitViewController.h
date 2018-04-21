//
//  BEARNewHabitViewController.h
//  Habit
//
//  Created by 熊伟 on 2017/10/17.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARBaseViewController.h"

@interface BEARNewHabitViewController : BEARBaseViewController
- (instancetype)initWithModify:(BEARHabitItem*)habitItem;
- (instancetype)initWithExistHabits:(NSArray<BEARHabitItem*>*)habits;
@end
