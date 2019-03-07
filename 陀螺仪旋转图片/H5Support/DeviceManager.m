//
//  DeviceManager.m
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import "DeviceManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface DeviceManager ()<AVAudioRecorderDelegate,CLLocationManagerDelegate>

/// 扫描二维码相关
@property(nonatomic,strong) AVAudioSession * session ;
@property(nonatomic,strong) AVAudioRecorder * recorder ;
@property(nonatomic,strong) NSTimer * levelTimer ;

/// 蓝牙相关
@property(nonatomic,strong) CLLocationManager * locationManager ;
@property(nonatomic,strong) CLBeaconRegion * beaconRegion ;
/// 陀螺仪
@property(nonatomic,strong) CMMotionManager * motionManager ;

@end


@implementation DeviceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self session];
    }
    return self;
}

#pragma mark - 陀螺仪相关

- (void)startGyro {
    [self motionManager];
}
/// 参考文章 https://www.jianshu.com/p/5bf81ef8d35a
- (CMMotionManager *)motionManager {
    if (_motionManager == nil) {
        //初始化全局管理对象
        CMMotionManager *manager = [[CMMotionManager alloc] init];
        //判断陀螺仪可不可以，判断陀螺仪是不是开启
        if ([manager isGyroAvailable] && ![manager isGyroActive]){
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            //告诉manager，更新频率是100Hz
            manager.gyroUpdateInterval = 0.01;
            //Push方式获取和处理数据,陀螺仪数据
            [manager startGyroUpdatesToQueue:queue
                                 withHandler:^(CMGyroData *gyroData, NSError *error)
             {
                 NSLog(@"陀螺仪数据 x = %.04f y = %.04f z = %.04f", gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     Safe_Block(self.callBack,@(gyroData.rotationRate.y))
                 });

             }];
            NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
            manager.accelerometerUpdateInterval = 0.5;
            //Push方式获取和处理数据,加速计数据
            [manager startAccelerometerUpdatesToQueue:queue2
                                          withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
             {
                 NSLog(@"加速计数据 X = %.04f Y = %.04f Z = %.04f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z);
             }];
            
            
        }
        _motionManager = manager;
    }
    return _motionManager;
}



#pragma mark - 蓝牙相关

- (void)startBeacon{
    
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:{

                [self.locationManager requestAlwaysAuthorization];
                // 第一次请求完了之后,用户点击完成后,在调用才知道结果
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self startBeacon];
                });
            }

                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
                [self.locationManager startMonitoringForRegion:self.beaconRegion];
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:beacons.count];
    for (CLBeacon *beacon in beacons) {
        NSLog(@" rssi is :%ld",(long)beacon.rssi);
        NSLog(@" beacon proximity :%ld",(long)beacon.proximity);
        NSLog(@" accuracy : %f",beacon.accuracy);
        NSLog(@" proximityUUID : %@",beacon.proximityUUID.UUIDString);
        NSLog(@" major :%ld",(long)beacon.major.integerValue);
        NSLog(@" minor :%ld",(long)beacon.minor.integerValue);
        
        NSDictionary * dic = @{@"uuid":beacon.proximityUUID.UUIDString,
                               @"distance":@(beacon.accuracy)
                               };
        [temp addObject:dic];
        
    }
    NSLog(@"%@",temp);
    
    if ([NSJSONSerialization isValidJSONObject:temp] == NO) {
        return;
    }
    
    NSData * data = [NSJSONSerialization dataWithJSONObject:temp options:NSJSONWritingPrettyPrinted error:nil];
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    Safe_Block(self.callBack,@{@"keyStr":@"bluetoothDistanceCallBack",@"data":str} )


}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}
/// 这里只是注册了一个UUID,但是听说要有不同的UUID,如果需要就用下面setupData的UUID数组
- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        NSUUID * uuid = [[NSUUID alloc]initWithUUIDString:Beacon_Device_UUID];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"test"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        
    }
    return _beaconRegion;
}
/// 下面是在https://github.com/AprilBrother/AprilBeacon-iOS-SDK搜集到的UUID,这个应该是全部的UUID了
- (NSArray *)setupData {
    NSArray *data = @[
                      @{
                          @"name" : @"AprilBeacon",
                          @"uuid" : @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
                          },
                      @{
                          @"name" : @"Apple AirLocate",
                          @"uuid" : @"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5",
                          },
                      @{
                          @"name" : @"Apple AirLocate2",
                          @"uuid" : @"74278BDA-B644-4520-8F0C-720EAF059935",
                          },
                      @{
                          @"name" : @"ESTimote",
                          @"uuid" : @"B9407F30-F5F8-466E-AFF9-25556B57FE6D",
                          },
                      
                      @{
                          @"name" : @"WeixinForBeacon",
                          @"uuid" : @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825",
                          },
                      @{
                          @"name" : @"EEK Beacon",
                          @"uuid" : @"B5B182C7-EAB1-4988-AA99-B5C1517008D9",
                          }
                      ];
    return data;
}




#pragma mark - 声音相关
/// 开启检测麦克风
- (void)startRecord {

    [self.recorder record];
    [self.levelTimer setFireDate:[NSDate distantPast]];
}
// 停止检测麦克风
- (void)stopRecord {
    [self.session setActive:NO error:nil];
    [self.recorder stop];
    [self.recorder deleteRecording];
    [self.levelTimer setFireDate:[NSDate distantFuture]];
}
// 音频播放
- (void)playVoice:(NSDictionary *)data {
    // 没有替换文件名
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);

    AudioServicesAddSystemSoundCompletion(soundID,NULL,NULL,soundCompleteCallBack,NULL);
    
    AudioServicesPlaySystemSound(soundID);
    
}
void soundCompleteCallBack(SystemSoundID soundID, void *clientData) {
    NSLog(@"播放完成");
}


/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
- (void)levelTimerCallback:(NSTimer *)timer {
    [self.recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [self.recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    NSLog(@"声音分贝数  -  %.2f",level*120);
    Safe_Block(self.callBack,@{@"keyStr":@"audioRecordCallBack",@"data":@(level*120)} )

}




- (AVAudioSession *)session {
    if (_session == nil) {
        
        AVAudioSession * session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [session setActive:YES error:nil];
        _session = session;

        //录音设置
        NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc]init];
        //设置录音格式
        [recordSetting  setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        //设置录音采样率（HZ）
        [recordSetting setValue:[NSNumber numberWithFloat:4000] forKey:AVSampleRateKey];
        //录音通道数
        [recordSetting setValue:[NSNumber  numberWithInt:1] forKey:AVNumberOfChannelsKey];
        //线性采样位数
        [recordSetting  setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
        //录音的质量
        [recordSetting  setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        //获取沙盒路径 作为存储录音文件的路径
        NSString * strUrl = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        NSLog(@"path = %@",strUrl);
        //创建url
        NSURL * url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/voice.aac",strUrl]];

        NSError * error ;
        //初始化AVAudioRecorder
        self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
        //开启音量监测
        self.recorder.meteringEnabled = YES;
        self.recorder.delegate = self;
        
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        [self.levelTimer setFireDate:[NSDate distantFuture]];
        
        if(error){
            NSLog(@"创建录音对象时发生错误，错误信息：%@",error.localizedDescription);
        }
        
    }
    return _session;
    
}





@end
