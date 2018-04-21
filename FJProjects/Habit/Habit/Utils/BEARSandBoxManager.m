//
//  BEARSandBoxManager.m
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARSandBoxManager.h"

@implementation BEARSandBoxManager


#pragma mark----获取沙盒路径
+(NSString *)filePath:(NSString *)fileName
{
    //获取沙盒目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //保存文件名称
    NSString * imageDocument = [paths[0] stringByAppendingPathComponent:@"diaryImg"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:imageDocument]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDocument
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    NSString *filePath=[imageDocument stringByAppendingPathComponent:fileName];
    return filePath;
}

+(UIImage *)loadImageFromSandbox:(NSString *)imageName
{
    //获取沙盒路径
    NSString *filePath=[self filePath:imageName];
    //根据路径读取image
    UIImage *image=[UIImage imageWithContentsOfFile:filePath];
    
    return image;
}

+(void)saveImageToSandbox:(UIImage *)image
             andImageName:(NSString *)imageName
           andResultBlock:(resultBlock)block
{
    //高保真压缩图片，此方法可将图片压缩，但是图片质量基本不变，第二个参数为质量参数
    NSData *imageData=UIImageJPEGRepresentation(image, 0.5);
    //将图片写入文件
    NSString *filePath=[self filePath:imageName];
    //是否保存成功
    BOOL result=[imageData writeToFile:filePath atomically:YES];
    //保存成功传值到blcok中
    if (result) {
        block(result);
    }
}

@end
