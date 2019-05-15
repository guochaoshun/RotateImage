//
//  AIBUtils.h
//  AnyiBeacon
//
//  Created by jaume on 30/04/14.
//  Copyright (c) 2014 Sandeep Mistry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AIBUtils : NSObject

+ (NSString *)stringForProximityValue:(CLProximity)proximity;

@end
