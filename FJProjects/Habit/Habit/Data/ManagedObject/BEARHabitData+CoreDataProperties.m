//
//  BEARHabitData+CoreDataProperties.m
//  Habit
//
//  Created by 熊伟 on 2017/10/31.
//  Copyright © 2017年 Bear. All rights reserved.
//
//

#import "BEARHabitData+CoreDataProperties.h"

@implementation BEARHabitData (CoreDataProperties)

+ (NSFetchRequest<BEARHabitData *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"HabitData"];
}

@dynamic count;
@dynamic date;
@dynamic diary;
@dynamic time;
@dynamic shortDate;
@dynamic shortTime;
@dynamic habit;

@end
