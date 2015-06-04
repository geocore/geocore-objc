//
//  MMGPlace.h
//  
//
//  Created by Purbo Mohamad on 5/20/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMGEvent;

@interface MMGPlaceQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;
- (PMKPromise *)events;
- (PMKPromise *)eventRelationships;

@end

@interface MMGPlace : MMGTaggable

@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double distanceLimit;

+ (MMGPlaceQuery *)query;

- (PMKPromise *)checkinFromLatitude:(double)latitude longitude:(double)longitude;
- (PMKPromise *)checkinUnrestrictedFromLatitude:(double)latitude longitude:(double)longitude;

@end

@interface MMGPlaceCheckin : MMGObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, assign) unsigned long long timestamp;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double accuracy;

@property (nonatomic, weak) NSDate *date;

@end

@interface MMGPlaceEvent : MMGRelationship

@property (nonatomic, strong) MMGPlace *place;
@property (nonatomic, strong) MMGEvent *event;

@end
