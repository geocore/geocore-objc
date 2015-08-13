//
//  MMGGenericResult.m
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@interface MMGGenericResult()

@property (readwrite, nonatomic, strong) NSDictionary *json;

@end

@implementation MMGGenericResult

- (id)initWithJSON:(NSDictionary *)jsonData {
    if (self = [super init]) {
        [self fromJSON:jsonData];
    }
    return self;
}

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.json = jsonData;
    return self;
}

- (NSDictionary *)toJSON {
    return [NSDictionary dictionaryWithDictionary:self.json];
}

@end

@interface MMGGenericCountResult()

@property (readwrite, nonatomic, assign) NSUInteger count;

@end

@implementation MMGGenericCountResult

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.count = [[jsonData optionalValueForKey:@"count" withDefaultValue:@(0)] unsignedIntegerValue];
    return self;
}

- (NSDictionary *)toJSON {
    return nil;
}

@end

