//
//  BEARDiaryTableViewCell.m
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDiaryTableViewCell.h"
#import "BEARDiaryModel.h"

@interface BEARDiaryTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;

@end


@implementation BEARDiaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)bindData:(BEARHabitData*)data
{
    BEARDiaryModel * model = [BEARDiaryModel yy_modelWithJSON:data.diary];
    if (model) {
        if (model.img && model.img.count > 0) {
            UIImage * image = [UIImage imageWithContentsOfFile:[BEARSandBoxManager filePath:model.img[0]]];
            if (image) {
                [self.headImgView setImage:image];
                self.headImgView.hidden = NO;
            }
            else{
                _titleLeadingConstraint.constant = 13;
            }
            
        }
        else{
            _titleLeadingConstraint.constant = 13;
        }
        self.contentLabel.text = model.text;
        self.timeLabel.text = [NSString stringWithFormat:@"%@  %@",data.shortDate,data.shortTime];
    }
    else{
        _titleLeadingConstraint.constant = 13;
        self.contentLabel.text = data.diary;
        self.timeLabel.text = [NSString stringWithFormat:@"%@  %@",data.shortDate,data.shortTime];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
