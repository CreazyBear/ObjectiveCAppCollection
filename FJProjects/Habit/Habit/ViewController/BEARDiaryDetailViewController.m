//
//  BEARDiaryDetailViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/11/4.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDiaryDetailViewController.h"
#import "BEARDiaryModel.h"
#import "BEARDiaryCollectionViewCell.h"

@interface BEARDiaryDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MWPhotoBrowserDelegate>
@property (nonatomic, strong) BEARHabitData *data;
@property (weak, nonatomic) IBOutlet UITextView *textContent;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, strong) BEARDiaryModel *model;
@end

@implementation BEARDiaryDetailViewController

- (instancetype)initWithItem:(BEARHabitData*)habitData
{
    self = [super init];
    if (self) {
        self.data = habitData;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.data.habit.name;
    self.imageCollectionView.hidden = YES;
    [self.textContent setEditable:NO];
    
    self.model = [BEARDiaryModel yy_modelWithJSON:self.data.diary];
    if (self.model) {
        if (self.model.img && self.model.img.count > 0) {

            [self.imageCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BEARDiaryCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([BEARDiaryCollectionViewCell class])];
            self.imageCollectionView.hidden = NO;
        }
        self.textContent.text = self.model.text;
    }
    else
    {
        self.textContent.text = self.data.diary;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark -  UICollectionViewDelegate,UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.img.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BEARDiaryCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BEARDiaryCollectionViewCell class]) forIndexPath:indexPath];
    [cell bindData:self.model.img[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Create browser (must be done each time photo browser is
    // displayed. Photo browser objects cannot be re-used)
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    // Customise selection images to change colours if required
    browser.customImageSelectedIconName = @"ImageSelected.png";
    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:indexPath.row];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.model.img.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.model.img.count) {
        return [MWPhoto photoWithImage:[UIImage imageNamed:[BEARSandBoxManager filePath:self.model.img[index]]]];
    }
    return nil;
}

@end
