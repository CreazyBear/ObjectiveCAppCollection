//
//  FJMKAnnotation.h
//  FJHistoryLine
//
//  Created by Bear on 2018/1/23.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FJMKAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * subtitle;
//街道属性信息
@property (nonatomic , copy) NSString * streetAddress ;
// 城市信息属性
@property (nonatomic ,copy) NSString * city ;
// 州，省 市 信息
@property(nonatomic ,copy ) NSString * state ;
//邮编
@property (nonatomic ,copy) NSString * zip  ;

@end
