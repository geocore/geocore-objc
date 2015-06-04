//
//  MMGFeed.m
//  
//
//  Created by Purbo Mohamad on 6/2/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@interface MMGFeedOperation()

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *content;

@end

@interface MMGFeedQuery()

@property (nonatomic, assign, readwrite) unsigned long long earliestTimestamp;
@property (nonatomic, assign, readwrite) unsigned long long startTimestamp;
@property (nonatomic, assign, readwrite) unsigned long long endTimestamp;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger numberPerPage;

@end

@interface MMGFeed()

@property (nonatomic, assign, readwrite) unsigned long long timestamp;

@end

@implementation MMGFeed

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.id = [jsonData optionalValueForKey:@"id" withDefaultValue:nil];
    self.type = [jsonData optionalValueForKey:@"type" withDefaultValue:nil];
    self.timestamp = [[jsonData optionalValueForKey:@"timestamp" withDefaultValue:@(0)] unsignedLongLongValue];
    self.content = [jsonData optionalValueForKey:@"objContent" withDefaultValue:[NSDictionary dictionary]];
    return self;
}

- (NSDictionary *)toJSON {
    if (self.content && [_content count] > 0) {
        return [NSDictionary dictionaryWithDictionary:_content];
    } else {
        return [NSDictionary dictionary];
    }
}

- (NSDate *)date {
    return [NSDate dateWithTimeIntervalSince1970:([[NSNumber numberWithUnsignedLongLong:self.timestamp] doubleValue] / 1000)];
}

- (void)setDate:(NSDate *)date {
    self.timestamp = [[NSNumber numberWithDouble:date.timeIntervalSince1970 * 1000]
                      unsignedLongLongValue];
}

- (PMKPromise *)post {
    NSString *resolvedType = self.type;
    if (!resolvedType && self.id) {
        // try to resolve type by using first 3 letters of the ID
        if ([self.id hasPrefix:@"PRO"]) {
            resolvedType = @"jp.geocore.entity.Project";
        } else if ([self.id hasPrefix:@"USE"]) {
            resolvedType = @"jp.geocore.entity.User";
        } else if ([self.id hasPrefix:@"GRO"]) {
            resolvedType = @"jp.geocore.entity.Group";
        } else if ([self.id hasPrefix:@"PLA"]) {
            resolvedType = @"jp.geocore.entity.Place";
        } else if ([self.id hasPrefix:@"EVE"]) {
            resolvedType = @"jp.geocore.entity.Event";
        } else if ([self.id hasPrefix:@"ITE"]) {
            resolvedType = @"jp.geocore.entity.Item";
        } else if ([self.id hasPrefix:@"TAG"]) {
            resolvedType = @"jp.geocore.entity.Tag";
        }
    }
    return [[[[[MMGFeedOperation operation]
                                 withId:self.id]
                                 withType:resolvedType]
                                 withContent:[self toJSON]]
                                 post];
}

@end

@implementation MMGFeedOperation

+ (instancetype)operation {
    return [MMGFeedOperation new];
}

- (instancetype)withType:(NSString *)type {
    self.type = type;
    return self;
}

- (instancetype)withContent:(NSDictionary *)content {
    self.content = content;
    return self;
}

- (PMKPromise *)post {
    NSString *path = [self buildPath:@"/objs" withIdForSubPath:@"/feed"];
    if (path && _content) {
        return [[Geocore instance] POST:path
                             parameters:self.type ? @{@"type": _type} : nil
                                   body:_content
                            resultClass:[MMGFeed class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id or content is not set"}]];
    }
}

@end

@implementation MMGFeedQuery

- (id)init {
    if (self = [super init]) {
        self.earliestTimestamp = 0;
        self.startTimestamp = 0;
        self.endTimestamp = 0;
        self.page = 0;
        self.numberPerPage = 0;
    }
    return self;
}

+ (instancetype)query {
    return [MMGFeedQuery new];
}

- (PMKPromise *)all {
    NSString *path = [self buildPath:@"/objs" withIdForSubPath:@"/feed"];
    if (path) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if (_startTimestamp > 0 && _endTimestamp > 0) {
            [dict setObject:@(_startTimestamp) forKey:@"from_timestamp"];
            [dict setObject:@(_endTimestamp) forKey:@"to_timestamp"];
        } else if (_earliestTimestamp > 0) {
            [dict setObject:@(_earliestTimestamp) forKey:@"to_timestamp"];
        }
        
        if (self.page > 0) {
            [dict setObject:@(self.page) forKey:@"page"];
        }
        if (self.numberPerPage > 0) {
            [dict setObject:@(self.numberPerPage) forKey:@"num"];
        }
        
        return [[Geocore instance] GET:path
                            parameters:dict
                           resultClass:[MMGFeed class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (instancetype)notEarlierThan:(NSDate *)earliestDate {
    self.earliestTimestamp = [[NSNumber numberWithDouble:earliestDate.timeIntervalSince1970 * 1000] unsignedLongLongValue];
    return self;
}

- (instancetype)startingAt:(NSDate *)startDate {
    self.startTimestamp = [[NSNumber numberWithDouble:startDate.timeIntervalSince1970 * 1000] unsignedLongLongValue];
    return self;
}

- (instancetype)endingAt:(NSDate *)endDate {
    self.endTimestamp = [[NSNumber numberWithDouble:endDate.timeIntervalSince1970 * 1000] unsignedLongLongValue];
    return self;
}

- (instancetype)page:(NSUInteger)page {
    self.page = page;
    return self;
}

- (instancetype)numberPerPage:(NSUInteger)numberPerPage {
    self.numberPerPage = numberPerPage;
    return self;
}

@end
