//
//  BEARHabitItem+CoreDataProperties.h
//  Habit
//
//  Created by 熊伟 on 2017/10/31.
//  Copyright © 2017年 Bear. All rights reserved.
//
//

#import "BEARHabitItem+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BEARHabitItem (CoreDataProperties)

+ (NSFetchRequest<BEARHabitItem *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *endTime;
@property (nonatomic) int64_t expectCount;
@property (nonatomic) int64_t expectTime;
@property (nonatomic) BOOL isCounter;
@property (nonatomic) BOOL isHasEnd;
@property (nonatomic) BOOL isNotify;
@property (nonatomic) BOOL isTimer;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *notifyTime;
@property (nullable, nonatomic, retain) NSSet<BEARHabitData *> *habitData;

@end

@interface BEARHabitItem (CoreDataGeneratedAccessors)

- (void)addHabitDataObject:(BEARHabitData *)value;
- (void)removeHabitDataObject:(BEARHabitData *)value;
- (void)addHabitData:(NSSet<BEARHabitData *> *)values;
- (void)removeHabitData:(NSSet<BEARHabitData *> *)values;

@end

NS_ASSUME_NONNULL_END
