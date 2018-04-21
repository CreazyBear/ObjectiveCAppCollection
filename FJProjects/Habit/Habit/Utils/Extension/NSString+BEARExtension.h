//
//  NSString+BEARExtension.h
//  Habit
//
//  Created by 熊伟 on 2017/10/23.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BEARExtension)
-(BOOL)isNilOrEmpty;
- (NSString *)MD5Digest;
- (NSDictionary *)convertToDictionary;
@end
