//
//  FJHomeViewController.m
//  FJQRScan
//
//  Created by 熊伟 on 2018/4/30.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "FJHomeViewController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface FJHomeViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation FJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
}

-(void)start {
    NSArray *arr = @[AVMetadataObjectTypeQRCode,
                     AVMetadataObjectTypeEAN13Code,
                     AVMetadataObjectTypeEAN8Code,
                     AVMetadataObjectTypeCode128Code];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [self setupSessionPreset:AVCaptureSessionPreset1920x1080
         metadataObjectTypes:arr
           currentController:self];

}

- (void)setupSessionPreset:(NSString *)sessionPreset
       metadataObjectTypes:(NSArray *)metadataObjectTypes
         currentController:(UIViewController *)currentController {
    
    if (sessionPreset == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 sessionPreset 参数不能为空" userInfo:nil];
    }
    
    if (metadataObjectTypes == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 metadataObjectTypes 参数不能为空" userInfo:nil];
    }
    
    if (currentController == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 currentController 参数不能为空" userInfo:nil];
    }
    
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建摄像设备输入流
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建元数据输出流
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 3(1)、创建摄像数据输出流
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）;
    // 如需限制扫描框范围，打开下一句注释代码并进行相应调整
    //    metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 4、创建会话对象
    _session = [[AVCaptureSession alloc] init];
    // 会话采集率: AVCaptureSessionPresetHigh
    _session.sessionPreset = sessionPreset;
    
    // 5、添加元数据输出流到会话对象
    [_session addOutput:metadataOutput];
    // 5(1)添加摄像输出流到会话对象；与 3(1) 构成识了别光线强弱
    [_session addOutput:_videoDataOutput];
    
    // 6、添加摄像设备输入流到会话对象
    [_session addInput:deviceInput];
    
    // 7、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    // @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
    metadataOutput.metadataObjectTypes = metadataObjectTypes;
    
    // 8、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    // 保持纵横比；填充层边界
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    _videoPreviewLayer.frame = CGRectMake(x, y, w, h);
    [currentController.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    // 9、启动会话
    [_session startRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    [self.session stopRunning];
    [metadataObjects enumerateObjectsUsingBlock:^(__kindof AVMetadataObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"1111 ----- %@",obj);
    }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    

//    [self imageFromSampleBuffer:sampleBuffer];
    [self detactSampleButter:sampleBuffer];
    
}


/**
 将CMSampleBufferRef放入到CIDetect中进行识别

 @param sampleBuffer CMSampleBufferRef
 */
- (void)detactSampleButter:(CMSampleBufferRef) sampleBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    //识别图片:
    CIImage* ciimage = [CIImage imageWithCGImage:quartzImage];
    NSDictionary* opts = [NSDictionary dictionaryWithObject: CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:opts];
    NSArray* features = [detector featuresInImage:ciimage];
    if (features && features.count > 0) {
        for (CIQRCodeFeature *feature in features){
//            NSLog(@"2222 ----- %@",feature);
            //TODO: 取出二维码图片，进行处理
        }
    }
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
}


/**
 将CMSampleBufferRef转换为UIImage对象

 @param sampleBuffer CMSampleBufferRef
 @return UIImage
 */
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}


- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size

{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 4*size.width,
                                                 rgbColorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    NSParameterAssert(context);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
    
}
















@end
