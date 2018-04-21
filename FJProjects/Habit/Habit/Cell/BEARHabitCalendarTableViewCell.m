//
//  BEARHabitCalendarTableViewCell.m
//  Habit
//
//  Created by 熊伟 on 2017/10/30.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARHabitCalendarTableViewCell.h"

@interface BEARHabitCalendarTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *habitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *countOneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *countTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *countTwoNumLabel;
@property (weak, nonatomic) IBOutlet UIView *colorBlock;

@end


@implementation BEARHabitCalendarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.colorBlock.layer.cornerRadius = 5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)bindData:(BEARHabitItem*)habitItem currentDate:(NSArray<BEARHabitData*>*)data
{
    NSMutableArray<BEARHabitData*> * allData = [NSMutableArray new];
    [data enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.habit isEqual:habitItem]) {
            [allData addObject:obj];
        }
    }];
    
    
    __block NSInteger totalNum = 0;
    __block NSInteger totalTime = 0;
    self.habitNameLabel.text = habitItem.name;
    if (habitItem.isCounter && habitItem.isTimer) {
        [allData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalNum += obj.count;
            totalTime += obj.time;
        }];
        _countOneLabel.text = @"计时";
        _countTwoLabel.text = @"计数";
        _countOneNumLabel.text = [NSString stringWithFormat:@"%ld",totalTime];
        _countTwoNumLabel.text = [NSString stringWithFormat:@"%ld",totalNum];
        _countTwoNumLabel.hidden = NO;
        _countTwoLabel.hidden = NO;
        if (totalTime >= habitItem.expectTime && totalNum >= habitItem.expectCount) {
            self.colorBlock.backgroundColor = [UIColor greenColor];
        }
        else if (totalTime < habitItem.expectTime && totalNum < habitItem.expectCount) {
            self.colorBlock.backgroundColor = [UIColor redColor];
        }
        else{
            self.colorBlock.backgroundColor = [UIColor orangeColor];
        }
    }
    else if (habitItem.isCounter && !habitItem.isTimer) {
        [allData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalNum += obj.count;
        }];
        _countOneLabel.text = @"计数";
        _countOneNumLabel.text = [NSString stringWithFormat:@"%ld",totalNum];
        _countTwoNumLabel.hidden = YES;
        _countTwoLabel.hidden = YES;
        if (totalNum >= habitItem.expectCount) {
            self.colorBlock.backgroundColor = [UIColor greenColor];
        }
        else{
            self.colorBlock.backgroundColor = [UIColor redColor];
        }
    }
    else if (!habitItem.isCounter && habitItem.isTimer) {
        [allData enumerateObjectsUsingBlock:^(BEARHabitData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            totalTime += obj.time;
        }];
        _countOneLabel.text = @"计时";
        _countOneNumLabel.text = [NSString stringWithFormat:@"%ld",totalTime];
        _countTwoNumLabel.hidden = YES;
        _countTwoLabel.hidden = YES;
        if (totalTime >= habitItem.expectTime) {
            self.colorBlock.backgroundColor = [UIColor greenColor];
        }
        else{
            self.colorBlock.backgroundColor = [UIColor redColor];
        }

    }
}

@end
