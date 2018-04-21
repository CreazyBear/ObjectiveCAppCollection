//
//  BEARHabitItem+CoreDataProperties.m
//  Habit
//
//  Created by 熊伟 on 2017/10/31.
//  Copyright © 2017年 Bear. All rights reserved.
//
//

#import "BEARHabitItem+CoreDataProperties.h"

@implementation BEARHabitItem (CoreDataProperties)

+ (NSFetchRequest<BEARHabitItem *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"HabitItem"];
}

@dynamic endTime;
@dynamic expectCount;
@dynamic expectTime;
@dynamic isCounter;
@dynamic isHasEnd;
@dynamic isNotify;
@dynamic isTimer;
@dynamic name;
@dynamic notifyTime;
@dynamic habitData;

@end
