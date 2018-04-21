//
//  BEARHabitDetailViewController.h
//  Habit
//
//  Created by 熊伟 on 2017/11/1.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARBaseViewController.h"

@interface BEARHabitDetailViewController : BEARBaseViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                  withHabitItem:(BEARHabitItem*)habitItem;
@end
