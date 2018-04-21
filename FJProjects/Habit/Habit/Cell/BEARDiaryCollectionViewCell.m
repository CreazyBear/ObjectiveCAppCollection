//
//  BEARDiaryCollectionViewCell.m
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDiaryCollectionViewCell.h"

@interface BEARDiaryCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BEARDiaryCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)bindData:(NSString*)fileName
{
    [self.imageView setImage:[UIImage imageNamed:[BEARSandBoxManager filePath:fileName]]];
}

@end
