//
//  BEARDIDIViewController.m
//  Habit
//
//  Created by 熊伟 on 2017/10/28.
//  Copyright © 2017年 Bear. All rights reserved.
//

#import "BEARDIDIViewController.h"
#import <Photos/Photos.h>
#import "BEARDiaryModel.h"

#define startTagNum 100


@interface BEARDIDIViewController ()<TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) BEARHabitItem *habitItem;

@property (weak, nonatomic) IBOutlet UILabel *lableOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UITextField *textFieldOne;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTwo;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIView *addPhotoView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *delete1;
@property (weak, nonatomic) IBOutlet UIImageView *delete2;
@property (weak, nonatomic) IBOutlet UIImageView *delete3;

@property (nonatomic, strong) NSMutableArray<UIImage*> * selectImages;
@property (nonatomic, strong) NSArray<UIImageView*> * imagesContainer;
@property (nonatomic, strong) NSArray<UIImageView*> * deleteContainer;
@property (nonatomic, assign) NSUInteger maxSelectImg;
@property (nonatomic, assign) BOOL keyboardVisiable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation BEARDIDIViewController

- (instancetype)initWithHabitItem:(BEARHabitItem*)habitItem
{
    self = [super init];
    if (self) {
        _habitItem = habitItem;
        _maxSelectImg = 3;
        _keyboardVisiable = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"打卡";
    self.widthConstraint.constant = SCREEN_WIDTH - 40;
    self.addPhotoView.layer.borderColor = [UIColor grayColor].CGColor;
    self.addPhotoView.layer.cornerRadius = 4;
    self.addPhotoView.layer.borderWidth = 1;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addPhotoGesture)];
    [self.addPhotoView addGestureRecognizer:tapGesture];
    
    self.textFieldOne.keyboardType = UIKeyboardTypeNumberPad;
    self.textFieldTwo.keyboardType = UIKeyboardTypeNumberPad;
    
    self.doneButton.layer.cornerRadius = 4;
    self.doneButton.layer.borderWidth = 1;
    self.doneButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 1;
    
    
    if (self.habitItem.isCounter && self.habitItem.isTimer) {
        //do nothing for now
    }
    else if (self.habitItem.isCounter && !self.habitItem.isTimer) {
        _labelTwo.hidden = YES;
        _textFieldTwo.hidden = YES;
        _textViewTopConstraint.constant = 30;
    }
    else if (!self.habitItem.isCounter && self.habitItem.isTimer) {
        _lableOne.text = @"计时";
        _labelTwo.hidden = YES;
        _textFieldTwo.hidden = YES;
        _textViewTopConstraint.constant = 30;
    }
    
    self.imagesContainer = @[_image1,_image2,_image3];
    self.deleteContainer = @[_delete1,_delete2,_delete3];
    [self setupDeleteTag];
    [self setupScrollView];
    [self smartPreEnter];
}


- (void) viewWillAppear:(BOOL)animated
{
    //注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    //注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [super viewWillAppear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    //解除键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    //解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}



-(void)setupScrollView
{
    UITapGestureRecognizer * tapScrollView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endUpEditing)];
    [self.scrollView addGestureRecognizer:tapScrollView];
}

-(void)smartPreEnter
{
    if (self.habitItem.expectCount >0 && self.habitItem.expectCount <=2) {
        self.textFieldOne.text = @"1";
    }
}

-(void)setupDeleteTag{

    [_deleteContainer enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tag = startTagNum + idx;
        obj.userInteractionEnabled = YES;
        UITapGestureRecognizer * removeTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelectedImg:)];
        [obj addGestureRecognizer:removeTapGesture];
    }];
}


-(void)removeSelectedImg:(UITapGestureRecognizer*)sender
{
    self.maxSelectImg += 1;
    if (sender.view.tag == 100) {
        [_selectImages removeObjectAtIndex:0];
    }
    else if(sender.view.tag == 101){
        [_selectImages removeObjectAtIndex:1];
    }
    else if(sender.view.tag == 102){
        [_selectImages removeObjectAtIndex:2];
    }
    
    [self setImages];
    
}

-(void)setImages
{
    [self.selectImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_imagesContainer[idx] setImage:obj];
        _imagesContainer[idx].hidden = NO;
        _deleteContainer[idx].hidden = NO;
    }];
    if (self.selectImages.count == 0) {
        [self.imagesContainer enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
            _deleteContainer[idx].hidden = YES;
        }];
    }
    else{
        [self.imagesContainer enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx> _selectImages.count-1) {
                obj.hidden = YES;
                _deleteContainer[idx].hidden = YES;
            }
        }];
    }
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self endUpEditing];
}

- (IBAction)onDoneButtonClicked:(id)sender {
    [self endUpEditing];
    dispatch_block_t block = ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"少了点什么"
                                                                                 message:@"填下打卡进度吧~" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    };
    
    BEARHabitData * habitData = [[BEARDatabaseManager share]newHabitData];
    habitData.date = [[NSDate alloc]init];
    habitData.shortDate = habitData.date.shortDateString;
    habitData.shortTime = habitData.date.shortTimeString;
    
    habitData.diary = [self generateFormatedDiary];
    if (self.habitItem.isCounter && self.habitItem.isTimer) {
        habitData.count = [_textFieldOne.text integerValue];
        habitData.time = [_textFieldTwo.text integerValue];
        if (habitData.count == 0 && habitData.time == 0) {
            block();
            return;
        }
    }
    else if (self.habitItem.isCounter && !self.habitItem.isTimer) {
        habitData.count = [_textFieldOne.text integerValue];
        if (habitData.count == 0) {
            block();
            return;
        }

    }
    else if (!self.habitItem.isCounter && self.habitItem.isTimer) {
        habitData.time = [_textFieldOne.text integerValue];
        if (habitData.time == 0) {
            block();
            return;
        }

    }
    [_habitItem addHabitDataObject:habitData];
    [[BEARDatabaseManager share]saveWithErrorBlock:^(NSError *error) {
#ifdef DEBUG
        NSLog(@"%@",error);
#endif
    } successBlock:^{
#ifdef DEBUG
        NSLog(@"save new habit to database success");
#endif
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

-(NSString*)generateFormatedDiary
{
    __block NSMutableArray<NSString*>* savedSandboxImg = [NSMutableArray new];
    [self.selectImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * imageName = [[NSString stringWithFormat:@"%@-%@-%ld",_habitItem.name,[NSDate new].shortDateString,idx] MD5Digest];
        imageName = [NSString stringWithFormat:@"%@.png",imageName];
        [BEARSandBoxManager saveImageToSandbox:obj
                                  andImageName:imageName
                                andResultBlock:^(BOOL success) {
                                    if (success) {
                                        [savedSandboxImg addObject:[NSString stringWithFormat:@"%@",imageName]];
                                    }
                                }];

    }];
    BEARDiaryModel * diaryModel = [BEARDiaryModel new];
    diaryModel.text = self.textView.text;
    diaryModel.img = savedSandboxImg;
    return [diaryModel yy_modelToJSONString];
}

-(void)endUpEditing
{
    [self.textFieldOne resignFirstResponder];
    [self.textFieldTwo resignFirstResponder];
    [self.textView resignFirstResponder];
}

-(void)addPhotoGesture{
    [self endUpEditing];
    if (self.maxSelectImg<=0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加图片上限"
                                                                                 message:@"最多支持添加3张图片，🙅问我为什么╮(￣▽￣)╭"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    dispatch_block_t block = ^{
        
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        imagePickerVc.maxImagesCount = self.maxSelectImg;
        imagePickerVc.allowPickingGif = NO;
        imagePickerVc.doneBtnTitleStr = @"完成";
        imagePickerVc.cancelBtnTitleStr = @"取消";
        imagePickerVc.previewBtnTitleStr = @"预览";
        imagePickerVc.fullImageBtnTitleStr = @"原图";
        
        
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos,
                                                         NSArray *assets,
                                                         BOOL isSelectOriginalPhoto) {
            if (!self.selectImages) {
                self.selectImages = [NSMutableArray new];
            }
            [self.selectImages addObjectsFromArray:photos.mutableCopy];
            self.maxSelectImg = _maxSelectImg - photos.count;
            [self setImages];
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    };
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    block();
                }
            }];
        }
        else if(authStatus == PHAuthorizationStatusRestricted){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:@"您的设备被限制使用图片功能" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
        else if(authStatus == PHAuthorizationStatusDenied){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
        else if(authStatus == PHAuthorizationStatusAuthorized)
        {
            block();
        }
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:@"您的设备不支持浏览图片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//点击取消按钮所执行的方法

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - keyboard
- (void) keyboardWillShow:(NSNotification *) notif
{
    if(_keyboardVisiable)
    {
        return;
    }
    
    // 获得键盘尺寸
    NSDictionary *info = notif.userInfo;
    NSValue *aValue = [info objectForKeyedSubscript:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    if ([self.textView isFirstResponder]) {
        //滚动到当前文本框
        CGPoint point = CGPointMake(0, _textView.frame.origin.y - SafeAreaTopHeight - 60);
        [self.scrollView setContentOffset:point];
    }
    
    _keyboardVisiable = YES;
    
}

- (void) keyboardWillHide:(NSNotification *) notif
{
    CGFloat duration = [[notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0.0f options:(curve<<16) animations:^{
        self.scrollView.contentInset = UIEdgeInsetsZero;
    } completion:nil];
    if (!_keyboardVisiable) {
        return;
    }
    _keyboardVisiable = NO;
}

@end
