//
//  MMGPlace.m
//  
//
//  Created by Purbo Mohamad on 5/20/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@implementation MMGPlaceQuery

+ (instancetype)query {
    return [MMGPlaceQuery new];
}

- (PMKPromise *)all {
    return [[Geocore instance] GET:[self buildPath:@"/places"]
                        parameters:[super buildQueryParameters]
                       resultClass:[MMGPlace class]];
}

- (PMKPromise *)events {
    NSString *path = [self buildPath:@"/places" withIdForSubPath:@"/events"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:[super buildQueryParameters]
                           resultClass:[MMGEvent class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)eventRelationships {
    NSString *path = [self buildPath:@"/places" withIdForSubPath:@"/events/relationships"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:[super buildQueryParameters]
                           resultClass:[MMGPlaceEvent class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

@end

@implementation MMGPlace

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.shortName = [jsonData optionalValueForKey:@"shortName" withDefaultValue:nil];
    self.shortDesc = [jsonData optionalValueForKey:@"shortDescription" withDefaultValue:nil];
    NSDictionary *point = [jsonData optionalValueForKey:@"point" withDefaultValue:@{}];
    self.latitude = [[point optionalValueForKey:@"latitude" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    self.longitude = [[point optionalValueForKey:@"longitude" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    self.distanceLimit = [[point optionalValueForKey:@"distanceLimit" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:self.shortName forKey:@"shortName"];
    [dict setOptionalValue:self.shortDesc forKey:@"shortDescription"];
    if (!isnan(self.latitude) && !isnan(self.longitude)) {
        [dict setOptionalValue:@{@"latitude": @(self.latitude), @"longitude": @(self.longitude)} forKey:@"point"];
    }
    [dict setOptionalValue:isnan(self.distanceLimit) ? nil : @(self.distanceLimit) forKey:@"distanceLimit"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (MMGPlaceQuery *)query {
    return [MMGPlaceQuery query];
}

- (PMKPromise *)checkinFromLatitude:(double)latitude longitude:(double)longitude {
    MMGPlaceCheckin *checkin = [MMGPlaceCheckin new];
    checkin.userId = [NSString stringWithString:[Geocore instance].user.id];
    checkin.placeId = [NSString stringWithString:self.id];
    checkin.date = [NSDate date];
    checkin.latitude = latitude;
    checkin.longitude = longitude;
    checkin.accuracy = 0.f;
    
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/places/%@/checkins", checkin.placeId]
                         parameters:nil
                               body:[checkin toJSON]
                        resultClass:[MMGPlaceCheckin class]];
}

- (PMKPromise *)checkinUnrestrictedFromLatitude:(double)latitude longitude:(double)longitude {
    MMGPlaceCheckin *checkin = [MMGPlaceCheckin new];
    checkin.userId = [NSString stringWithString:[Geocore instance].user.id];
    checkin.placeId = [NSString stringWithString:self.id];
    checkin.date = [NSDate date];
    checkin.latitude = latitude;
    checkin.longitude = longitude;
    checkin.accuracy = 0.f;
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/places/%@/checkins", checkin.placeId]
                         parameters:@{@"unrestricted": @"true"}
                               body:[checkin toJSON]
                        resultClass:[MMGPlaceCheckin class]];
}

@end

@implementation MMGPlaceCheckin

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.userId = [jsonData optionalValueForKey:@"userId" withDefaultValue:nil];
    self.placeId = [jsonData optionalValueForKey:@"placeId" withDefaultValue:nil];
    self.timestamp = [[jsonData optionalValueForKey:@"timestamp" withDefaultValue:@(0)] unsignedLongLongValue];
    self.latitude = [[jsonData optionalValueForKey:@"latitude" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    self.longitude = [[jsonData optionalValueForKey:@"longitude" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    self.accuracy = [[jsonData optionalValueForKey:@"accuracy" withDefaultValue:[NSDecimalNumber notANumber]] doubleValue];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:_userId forKey:@"userId"];
    [dict setOptionalValue:_placeId forKey:@"placeId"];
    if (_timestamp > 0) {
        [dict setOptionalValue:@(_timestamp) forKey:@"timestamp"];
    }
    if (!isnan(self.latitude) && !isnan(self.longitude)) {
        [dict setOptionalValue:@(_latitude) forKey:@"latitude"];
        [dict setOptionalValue:@(_longitude) forKey:@"longitude"];
    }
    if (!isnan(self.accuracy)) {
        [dict setOptionalValue:@(_accuracy) forKey:@"accuracy"];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDate *)date {
    return [NSDate dateWithTimeIntervalSince1970:([[NSNumber numberWithUnsignedLongLong:self.timestamp] doubleValue] / 1000)];
}

- (void)setDate:(NSDate *)date {
    self.timestamp = [[NSNumber numberWithDouble:date.timeIntervalSince1970 * 1000]
                      unsignedLongLongValue];
}

@end


@implementation MMGPlaceEvent

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    NSDictionary *pk = [jsonData optionalValueForKey:@"pk" withDefaultValue:@{}];
    NSDictionary *placeDict = [pk optionalValueForKey:@"place" withDefaultValue:nil];
    if (placeDict) {
        self.place = [[MMGPlace new] fromJSON:placeDict];
    }
    NSDictionary *eventDict = [pk optionalValueForKey:@"event" withDefaultValue:nil];
    if (eventDict) {
        self.event = [[MMGEvent new] fromJSON:eventDict];
    }
    return self;
}

@end
