//
//  MMGTrackPoint.m
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@implementation MMGTrackPoint

- (id)initWithId:(NSString *)id latitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy date:(NSDate *)date memo:(NSString *)memo {
    if (self = [super init]) {
        self.id = id;
        self.latitude = latitude;
        self.longitude = longitude;
        self.accuracy = accuracy;
        self.timestamp = [[NSNumber numberWithDouble:date.timeIntervalSince1970*1000] unsignedLongLongValue];
        self.memo = memo;
    }
    return self;
}

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.id = [jsonData valueForKey:@"id"];
    self.memo = [jsonData optionalValueForKey:@"memo" withDefaultValue:nil];
    self.timestamp = [[jsonData valueForKey:@"timestamp"] unsignedLongLongValue];
    self.latitude = [[jsonData valueForKey:@"latitude"] doubleValue];
    self.longitude = [[jsonData valueForKey:@"longitude"] doubleValue];
    self.accuracy = [[jsonData valueForKey:@"accuracy"] doubleValue];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithUnsignedLongLong:self.timestamp]  forKey:@"timestamp"];
    [dict setValue:[NSNumber numberWithDouble:self.latitude]  forKey:@"latitude"];
    [dict setValue:[NSNumber numberWithDouble:self.longitude]  forKey:@"longitude"];
    [dict setValue:[NSNumber numberWithDouble:self.accuracy]  forKey:@"accuracy"];
    [dict setValue:self.id  forKey:@"id"];
    [dict setOptionalValue:self.memo forKey:@"memo"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
