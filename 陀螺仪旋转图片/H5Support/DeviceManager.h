//
//  DeviceManager.h
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceManager : NSObject

@property(nonatomic,copy) callBackBlock callBack ;


/// 开始蓝牙监听
- (void)startBeacon;

/// 播放声音
- (void)playVoice:(NSDictionary *)data;
/// 开始录音
- (void)startRecord;
/// 结束录音
- (void)stopRecord;

/// 开始监听陀螺仪
- (void)startGyro;

@end

NS_ASSUME_NONNULL_END
