//
//  MyCamera.m
//  WPYCustomControls
//
//  Created by 王鹏宇 on 2018/6/13.
//  Copyright © 2018年 wpy_person. All rights reserved.
//

#import "MyCamera.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHAsset.h>

#import "SDPhotoBrowser.h"

@interface MyCamera ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,SDPhotoBrowserDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风 （音频输入）
@property (nonatomic, strong)AVCaptureDevice * device;

//AVCaptureDeviceInput  输入设备 它使用 AVCaptureDevice 来初始化
@property (nonatomic, strong)AVCaptureDeviceInput * inputDevice;
//当启动摄像头开始捕获输入
@property (nonatomic, strong)AVCaptureMetadataOutput * output;
@property (nonatomic, strong)AVCaptureStillImageOutput * imageOutPut;

//session 由它把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong)AVCaptureSession * session;

@property (nonatomic, strong)AVCaptureVideoPreviewLayer * previewLayer;

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;


@property (nonatomic, strong)UIImageView * imageView;
@property (nonatomic, strong)UIView * focusView;
@property (nonatomic, strong)UIImage * image;

@property (nonatomic)BOOL isflashOn;
@property (nonatomic)BOOL canCa;
@end

@implementation MyCamera

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
        [self IsOk];
        [self initCamera];
        [self setup];
    
}


- (void)IsOk {
    
    //相机权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限
        authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问
    {
        // 无权限 引导去开启
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}


- (void)setup {
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    
    
    [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关"] forState:UIControlStateNormal];
    _isflashOn = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
//        [_device setFlashMode:AVCaptureFlashModeOff];
//        _isflashOn = NO;
//
//    }
}

- (void)initCamera {
    
    //使用AVMediaTypeVideo 指明self.device 代表视频 默认使用后置摄像头进项初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用设备初始化输入
    self.inputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc] init];
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc] init];
//    if([self.session canSetSessionPreset:AVCaptureSessionPreset1920x1080]){
//        self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
//    }
    
    if([self.session canAddInput:self.inputDevice]){
        
        [self.session addInput:self.inputDevice];
    }
    
    if ([self.session canAddOutput:self.imageOutPut]) {
        
        [self.session addOutput:self.imageOutPut];
    }
    
    //使用 self.session. 初始化预览层  self.session负责驱动input信息采集layer
    //负责把图像渲染显示
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    self.previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer below:self.photoButton.layer];
    
    //开始启动
    [self.session startRunning];
   
    
    if([_device lockForConfiguration:nil]){
        
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        if (![_device hasFlash]) return;
        
        if (_device.flashMode == AVCaptureFlashModeOn) {
            
            [_device setFlashMode:AVCaptureFlashModeOff];
            self.isflashOn = NO;
        }
        
        [_device unlockForConfiguration];
    }
}


- (IBAction)goBigImage:(UIButton *)sender {
    
    if (self.thumbImageView.image) {
        SDPhotoBrowser *browser = [SDPhotoBrowser new];
        browser.sourceImagesContainerView = sender;
        browser.imageCount = 1;
        browser.currentImageIndex = 0;
        browser.delegate = self;
        //    browser.type = 2;
        [browser show];
    }
}

- (IBAction)cancelAction:(UIButton *)sender {
    
    [self.session stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)takePicturesAction:(UIButton *)sender {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        [self shutterCamera];
        return;
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ((status == PHAuthorizationStatusRestricted) || (status == PHAuthorizationStatusDenied) || (status == PHAuthorizationStatusNotDetermined))
            {
                              UIAlertController * alertVC  =  [UIAlertController alertControllerWithTitle:@"" message:@"照片权限未开启" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * goAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
                        [[UIApplication sharedApplication]openURL:url];
                    }
                }];
                
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                
                [alertVC addAction:cancelAction];
                [alertVC addAction:goAction];
                
                
                [self presentViewController:alertVC animated:true completion:nil];
            }else{
                
                [self shutterCamera];
            }
        });
    }];
}
#pragma mark - 截取照片
- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
       // [self.session stopRunning];
        [self saveImageToPhotoAlbum:self.image];
    }];
}

- (IBAction)SwitchCameraAction:(UIButton *)sender {
    
        NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
        if (cameraCount > 1) {
            NSError *error;
            
            CATransition *animation = [CATransition animation];
            
            animation.duration = .5f;
            
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            animation.type = @"oglFlip";
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            AVCaptureDevicePosition position = [[_inputDevice device] position];
            if (position == AVCaptureDevicePositionFront){
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                animation.subtype = kCATransitionFromLeft;
            }
            else {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                animation.subtype = kCATransitionFromRight;
            }
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            [self.previewLayer addAnimation:animation forKey:nil];
            if (newInput != nil) {
                [self.session beginConfiguration];
                [self.session removeInput:_inputDevice];
                if ([self.session canAddInput:newInput]) {
                    [self.session addInput:newInput];
                    self.inputDevice = newInput;
                    
                } else {
                    [self.session addInput:self.inputDevice];
                }
                
                [self.session commitConfiguration];
                
            } else if (error) {
                NSLog(@"toggle carema failed, error = %@", error);
            }
            
        }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

- (IBAction)flashAction:(UIButton *)sender {
    
    if ([_device lockForConfiguration:nil]) {
        if (_isflashOn) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
                _isflashOn = NO;
                [_flashButton setImage:[UIImage imageNamed:@"闪光灯-关"] forState:UIControlStateNormal];
            }
        }else{
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
                _isflashOn = YES;
                [_flashButton setImage:[UIImage imageNamed:@"闪光灯-开"] forState:UIControlStateNormal];
            }
        }
        
        [_device unlockForConfiguration];
    }
}


- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }
    
}


#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{

    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        self.thumbImageView.image = image;
    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
//                                                    message:msg
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
}

-(void)cancle{
    [self.imageView removeFromSuperview];
    [self.session startRunning];
}

#pragma  mark --SDPhotoBrowser

-(UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    
    return  self.thumbImageView.image;
}

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
