//
//  BEARDatabaseManager.h
//  Habit
//
//  Created by 熊伟 on 2017/10/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <FJMacroSingleInstance.h>
@class BEARHabitItem,BEARHabitData;

extern NSString * const habitItemEntityName;
extern NSString * const habitDataEntityName;

extern NSString * const deleteDataNotification;
extern NSString * const saveDataNotification;

@interface BEARDatabaseManager : NSObject
SINGLETON_INTERFACE(BEARDatabaseManager,share);

-(BEARHabitItem*)newHabitItem;
-(BEARHabitData*)newHabitData;

-(void)saveWithErrorBlock:(void(^)(NSError* error))errorBlock
             successBlock:(void(^)(void))successBlock;

- (void)readEntity:(NSString*)entityName
      sequenceKeys:(NSArray *)sequenceKeys
         ascending:(BOOL)isAscending
         filterPredicate:(NSPredicate *)filterPredicate
           success:(void(^)(NSArray *results))success
              fail:(void(^)(NSError *error))fail;

-(void)deleteObj:(NSManagedObject*)obj;

@end
