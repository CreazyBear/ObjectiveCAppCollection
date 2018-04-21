//
//  BEARSandBoxManager.h
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  保存成功回调
 *
 *  @param success 保存成功的block
 */
typedef void(^resultBlock)(BOOL success);


@interface BEARSandBoxManager : NSObject
+(NSString *)filePath:(NSString *)fileName;
+(UIImage *)loadImageFromSandbox:(NSString *)imageName;
+(void)saveImageToSandbox:(UIImage *)image
             andImageName:(NSString *)imageName
           andResultBlock:(resultBlock)block;
@end
