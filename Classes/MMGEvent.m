//
//  MMGEvent.m
//  AnchorUp
//
//  Created by Purbo Mohamad on 5/20/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@implementation MMGEventQuery

+ (instancetype)query {
    return [MMGEventQuery new];
}

- (PMKPromise *)all {
    return [[Geocore instance] GET:[self buildPath:@"/events"]
                        parameters:[super buildQueryParameters]
                       resultClass:[MMGEvent class]];
}

@end

@implementation MMGEvent

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.timeStart = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"timeStart" withDefaultValue:nil]];
    self.timeEnd = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"timeEnd" withDefaultValue:nil]];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:self.timeStart forKey:@"timeStart"];
    [dict setOptionalValue:self.timeEnd forKey:@"timeEnd"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (MMGEventQuery *)query {
    return [MMGEventQuery query];
}

@end
