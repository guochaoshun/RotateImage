//
//  QRCodeViewController.m
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CoverView.h"

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, CALayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *scanLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLineTop;


//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;


@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self.captureSession startRunning];

    [self addCoverView];

}
- (IBAction)cancleScan:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void)addCoverView{
    CoverView * coverView = [[CoverView alloc]initWithFrame:self.view.bounds];
    [self.view insertSubview:coverView atIndex:1];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"扫描到内容 - %@",[metadataObj stringValue]);
            Safe_Block(self.callBack,[metadataObj stringValue])
            [self cancleScan:nil];
            
        }
    }
}

- (AVCaptureSession *)captureSession {
    if (_captureSession == nil) {
        
        NSError *error;
        
        //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //2.用captureDevice创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            NSLog(@"%@", [error localizedDescription]);
            return nil;
        }
        
        //3.创建媒体数据输出流
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        
        //4.实例化捕捉会话
        _captureSession = [[AVCaptureSession alloc] init];
        
        //4.1.将输入流添加到会话
        [_captureSession addInput:input];
        
        //4.2.将媒体输出流添加到会话中
        [_captureSession addOutput:captureMetadataOutput];
        
        //5.创建串行队列，并加媒体输出流添加到队列当中
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        //5.1.设置代理
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        //5.2.设置输出媒体数据类型为QRCode
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        //6.实例化预览图层
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        
        //7.设置预览图层填充方式
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        //8.设置图层的frame
        [_videoPreviewLayer setFrame:self.view.bounds];
        
        //9.将图层添加到预览view的图层上
        [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];

        //10.设置扫描范围
        captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
        
        //10.开始扫描
        [_captureSession startRunning];
        
        
    }
    return _captureSession;
}






@end
