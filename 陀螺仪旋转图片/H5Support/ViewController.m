//
//  ViewController.m
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "ViewController.h"
#import "DeviceManager.h"
#import "MBProgressHUD.h"
#import "QRCodeViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController ()<WKNavigationDelegate>

@property(nonatomic,strong) WKWebView * webView ;
@property(nonatomic,strong) DeviceManager * deviceManager ;

@property(nonatomic,strong) WKWebViewJavascriptBridge* bridge;

@property(nonatomic,strong) UIScrollView * sc ;
@property(nonatomic,strong) UIImageView * imageView ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.webView reload];

    // 根据陀螺仪旋转图片
    UIImage * image = [UIImage imageNamed:@"timg"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    UIScrollView * sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, Screen_Width, 300)];
    sc.contentSize = image.size;
    [sc setContentOffset:CGPointMake((image.size.width-Screen_Width)*0.5, 0)];
    [sc addSubview:imageView];
    [self.view addSubview:sc];
    self.sc = sc;
    self.imageView = imageView;

    [self.deviceManager startGyro];

    
}

- (void)didChangeY:(NSNumber *)num {
    
    CGPoint point = self.sc.contentOffset ;
    
    CGFloat targetPointX = point.x+num.doubleValue*self.imageView.image.size.width/Screen_Width ;
    if (targetPointX < 0) {
        targetPointX = 0;
    }
    if (targetPointX > self.imageView.image.size.width-Screen_Width) {
        targetPointX = self.imageView.image.size.width-Screen_Width;
    }
    [self.sc setContentOffset:CGPointMake(targetPointX, 0)];
    
}




#pragma mark - js调用,oc实现的方法
/// 手机振动
- (void)shake:(NSNumber *)data {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
/// 扫描二维码
- (void)gotoScanQRCode {
    QRCodeViewController * qrCode = [[QRCodeViewController alloc] init];
    WeakSelf
    [qrCode setCallBack:^(NSString * data) {
        [weakSelf.bridge callHandler:@"scanQRCodeCallBack" data:data];
    }];
    [self presentViewController:qrCode animated:YES completion:nil];
    
    
}
/// 显示加载动画
- (void)showLoading {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
/// 隐藏加载动画
- (void)hideLoading {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



- (WKWebView *)webView {
    if (_webView == nil) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
        
        [_webView  loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MainUrl]]];
        
        _webView.navigationDelegate = self;
        
        [self.view addSubview:_webView];
        
        // 注册事件及回调
        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
        [_bridge setWebViewDelegate:self];
        
        [WKWebViewJavascriptBridge enableLogging];
        
        
        /**
         注册好方法,等待被调用
         **/
        WeakSelf
        // 手机振动
        [_bridge registerHandler:@"shake" handler:^(NSNumber * data, WVJBResponseCallback responseCallback) {
            [weakSelf shake:data];
        }];
        // 扫描二维码
        [_bridge registerHandler:@"scanQRCode" handler:^(id data, WVJBResponseCallback responseCallback) {
            [weakSelf gotoScanQRCode];
        }];
        // 开启检测麦克风
        [_bridge registerHandler:@"startRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"%@",data);
            [weakSelf.deviceManager startRecord];
        }];
        // 停止检测麦克风
        [_bridge registerHandler:@"stopRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"%@",data);
            [weakSelf.deviceManager stopRecord];
            
        }];
        // 音频播放
        [_bridge registerHandler:@"playVoice" handler:^(id data, WVJBResponseCallback responseCallback) {
            [weakSelf.deviceManager playVoice:data];
        }];
        // 显示加载动画
        [_bridge registerHandler:@"showLoading" handler:^(id data, WVJBResponseCallback responseCallback) {
            [weakSelf showLoading];
        }];
        // 隐藏加载动画
        [_bridge registerHandler:@"hideLoading" handler:^(id data, WVJBResponseCallback responseCallback) {
            [weakSelf hideLoading];
        }];
        // 设置当前蓝牙UUID
        [_bridge registerHandler:@"setAtUUID" handler:^(id data, WVJBResponseCallback responseCallback) {
            [weakSelf.deviceManager startBeacon];
        }];
        // 刷新页面
        [_bridge registerHandler:@"reload" handler:^(id data, WVJBResponseCallback responseCallback) {
            NSLog(@"%@",data);
            [weakSelf.webView reload];
        }];
        
        
    }
    return _webView;
}



- (DeviceManager *)deviceManager {
    if (_deviceManager == nil) {
        _deviceManager = [[DeviceManager alloc]init];
        [_deviceManager startBeacon];
        [_deviceManager startUpdateHeading];

        WeakSelf
        [_deviceManager setCallBack:^(NSDictionary * data) {
            
            if ([data isKindOfClass:[NSNumber class]]) {
                [weakSelf didChangeY:(NSNumber *)data];
                return ;
            }
            [weakSelf.bridge callHandler:data[@"keyStr"] data:data[@"data"]];
            
            
        }];
    }
    return _deviceManager ;
}

@end
