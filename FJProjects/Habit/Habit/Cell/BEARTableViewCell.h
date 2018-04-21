//
//  BEARTableViewCell.h
//  Habit
//
//  Created by 熊伟 on 2017/10/24.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEARTableViewCell : UITableViewCell
-(void)bindData:(BEARHabitItem*)habitItem;
@end
