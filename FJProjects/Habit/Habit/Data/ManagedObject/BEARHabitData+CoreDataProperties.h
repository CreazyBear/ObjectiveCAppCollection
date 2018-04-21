//
//  BEARHabitData+CoreDataProperties.h
//  Habit
//
//  Created by 熊伟 on 2017/10/31.
//  Copyright © 2017年 Bear. All rights reserved.
//
//

#import "BEARHabitData+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BEARHabitData (CoreDataProperties)

+ (NSFetchRequest<BEARHabitData *> *)fetchRequest;

@property (nonatomic) int64_t count;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *diary;
@property (nonatomic) int64_t time;
@property (nullable, nonatomic, copy) NSString *shortDate;
@property (nullable, nonatomic, copy) NSString *shortTime;
@property (nullable, nonatomic, retain) BEARHabitItem *habit;

@end

NS_ASSUME_NONNULL_END
