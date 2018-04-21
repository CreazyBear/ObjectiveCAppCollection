//
//  BEARHabitCalendarTableViewCell.h
//  Habit
//
//  Created by 熊伟 on 2017/10/30.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEARHabitCalendarTableViewCell : UITableViewCell
-(void)bindData:(BEARHabitItem*)habitItem currentDate:(NSArray<BEARHabitData*>*)data;
@end
