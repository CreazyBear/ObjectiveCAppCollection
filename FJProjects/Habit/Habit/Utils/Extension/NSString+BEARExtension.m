//
//  NSString+BEARExtension.m
//  Habit
//
//  Created by 熊伟 on 2017/10/23.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "NSString+BEARExtension.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (BEARExtension)

-(BOOL)isNilOrEmpty
{
    NSCharacterSet * emptyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n"];
    
    if (!self || [self stringByTrimmingCharactersInSet:emptyCharacterSet].length == 0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (NSString *)MD5Digest
{
    const char* input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

- (NSDictionary *)convertToDictionary
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
