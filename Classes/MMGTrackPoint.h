//
//  MMGTrackPoint.h
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGTrackPoint : NSObject<MMGJSONSerializable>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, assign) unsigned long long timestamp;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double accuracy;

- (id)initWithId:(NSString *)id latitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy date:(NSDate *)date memo:(NSString *)memo;

@end
