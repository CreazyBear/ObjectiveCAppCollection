//
//  BEARTextField.m
//  Habit
//
//  Created by 熊伟 on 2017/10/22.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARTextField.h"

@interface BEARTextField()
@property (nonatomic, assign) CGFloat paddingLeft;
@property (nonatomic, assign) CGFloat paddingRight;
@property (nonatomic, assign) CGFloat paddingTop;
@property (nonatomic, assign) CGFloat paddingBottom;
@property (nonatomic, assign) BOOL isPaddingEnable;
@end

@implementation BEARTextField

- (void)setPaddingLeft:(float)left right:(float)right top:(float)top bottom:(float)bottom {
    _isPaddingEnable = YES;
    _paddingLeft = left;
    _paddingRight = right;
    _paddingTop = top;
    _paddingBottom = bottom;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    if (_isPaddingEnable) {
        return CGRectMake(bounds.origin.x + _paddingLeft, bounds.origin.y + _paddingTop, bounds.size.width - _paddingRight, bounds.size.height - _paddingBottom);
    } else {
        return bounds;
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
