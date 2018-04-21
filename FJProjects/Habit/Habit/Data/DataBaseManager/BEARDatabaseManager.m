//
//  BEARDatabaseManager.m
//  Habit
//
//  Created by 熊伟 on 2017/10/19.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDatabaseManager.h"

NSString * const habitItemEntityName = @"HabitItem";
NSString * const habitDataEntityName = @"HabitData";
NSString * const deleteDataNotification = @"deleteDataNotification";
NSString * const saveDataNotification = @"saveDataNotification";

@interface BEARDatabaseManager()
/**
 *  获取数据库存储的路径
 */
@property (nonatomic,copy) NSString *sqlPath;
/**
 *  获取.xcdatamodeld文件的名称
 */
@property (nonatomic,copy) NSString *modelName;

/**
 *  数据模型对象
 */
@property (nonatomic,strong) NSManagedObjectModel *model;
/**
 *  上下文
 */
@property (nonatomic,strong) NSManagedObjectContext *managedObjCtx;
/**
 *  持久性存储区
 */
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistent;


@end


@implementation BEARDatabaseManager
SINGLETON_IMPLEMENTION(BEARDatabaseManager,share);
#pragma mark - private
-(NSManagedObjectContext *)managedObjCtx
{
    if (!_managedObjCtx) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Habit" withExtension:@"momd"];
        self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        self.persistent = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        _managedObjCtx = [[NSManagedObjectContext alloc] initWithConcurrencyType:(NSPrivateQueueConcurrencyType)];
        
        NSError *error = nil;
        self.sqlPath = [[self documentPath] stringByAppendingPathComponent:@"Habit.sqlite"];
        
        [self.persistent addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:[NSURL fileURLWithPath:self.sqlPath]
                                            options:nil
                                              error:&error];
        if (error) {
#ifdef DEBUG
            NSLog(@"添加数据库失败:%@",error);
#endif
        } else {

#ifdef DEBUG
            NSLog(@"添加数据库成功");
#endif
            _managedObjCtx.persistentStoreCoordinator = self.persistent;
        }
    }
    return _managedObjCtx;
}

-(NSString*)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

#pragma mark - public
-(void)saveWithErrorBlock:(void(^)(NSError* error))errorBlock
             successBlock:(void(^)(void))successBlock
{
    NSError *error = nil;
    BOOL result = [self.managedObjCtx save:&error];
    if (!result) {
        !errorBlock?:errorBlock(error);
    } else {
        !successBlock?:successBlock();
        [[NSNotificationCenter defaultCenter]postNotificationName:saveDataNotification object:nil];
    }
}

// 查询数据
- (void)readEntity:(NSString*)entityName
      sequenceKeys:(NSArray *)sequenceKeys
         ascending:(BOOL)isAscending
         filterPredicate:(NSPredicate *)filterPredicate
           success:(void(^)(NSArray *results))success
              fail:(void(^)(NSError *error))fail
{
    // 1.初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 2.设置要查询的实体
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.managedObjCtx];
    request.entity = desc;
    // 3.设置查询结果排序
    if (sequenceKeys && sequenceKeys.count>0) { // 如果进行了设置排序
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *key in sequenceKeys) {
            /**
             *  设置查询结果排序
             *  sequenceKey:根据某个属性（相当于数据库某个字段）来排序
             *  isAscending:是否升序
             */
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending];
            [array addObject:sort];
        }
        if (array.count>0) {
            request.sortDescriptors = array;// 可以添加多个排序描述器，然后按顺序放进数组即可
        }
    }
    // 4.设置条件过滤
    if (filterPredicate) { // 如果设置了过滤语句
        request.predicate = filterPredicate;
    }
    // 5.执行请求
    NSError *error = nil;
    NSArray *objs = [self.managedObjCtx executeFetchRequest:request error:&error]; // 获得查询数据数据集合
    if (error) {
        if (fail) {
            fail(error);
        }
    } else{
        if (success) {
            success(objs);
        }
    }
}

-(void)deleteObj:(NSManagedObject*)obj
{
    [self.managedObjCtx deleteObject:obj];
    [[NSNotificationCenter defaultCenter]postNotificationName:deleteDataNotification object:nil];
}

-(BEARHabitItem*)newHabitItem
{
    return [NSEntityDescription insertNewObjectForEntityForName:habitItemEntityName
                                         inManagedObjectContext:self.managedObjCtx];
}

-(BEARHabitData*)newHabitData
{
    return [NSEntityDescription insertNewObjectForEntityForName:habitDataEntityName
                                         inManagedObjectContext:self.managedObjCtx];
}
@end
