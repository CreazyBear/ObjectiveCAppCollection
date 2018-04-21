//
//  FJMKAnnotation.m
//  FJHistoryLine
//
//  Created by Bear on 2018/1/23.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "FJMKAnnotation.h"

@implementation FJMKAnnotation
-(NSString *)description {
    return [NSString stringWithFormat:@"\ntitle:%@\nsubtitle:%@\nstreetAddress:%@\ncity:%@\nstate:%@\nzip:%@",self.title,self.subtitle,self.streetAddress,self.city,self.state,self.zip];
}
@end
