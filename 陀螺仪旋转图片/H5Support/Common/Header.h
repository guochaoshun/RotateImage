//
//  Header.h
//  H5Support
//
//  Created by apple on 2019/3/4.
//  Copyright © 2019 apple. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define MainUrl  @"http://192.168.2.27:8080/"

#define Beacon_Device_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"


// 一般是NSDictionary , @{@"keyStr":@"",@"data":model};
typedef void(^callBackBlock)(id data);
#define Lazy_Init(object, assignment) if (object==nil) { object=assignment; } return object;
//  self弱引用
#define WeakSelf  __weak __typeof(self)weakSelf = self;
#define po(object) NSLog(@"%@:%@",object.class,object);
#define poMessage(message,object) NSLog(@"%@---%@",message,object);
#define Safe_Block(block, ...) if (block) { block(__VA_ARGS__); };
#define Screen_Width [[UIScreen mainScreen] bounds].size.width
#define Screen_Height [[UIScreen mainScreen] bounds].size.height
#define UIColorFromRGB(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]


#endif /* Header_h */
