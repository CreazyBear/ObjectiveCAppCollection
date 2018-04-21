//
//  BEARDiaryModel.h
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BEARDiaryModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSArray<NSString*> *img;
@end
