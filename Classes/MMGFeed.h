//
//  MMGFeed.h
//
//
//  Created by Purbo Mohamad on 6/2/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGFeedOperation : MMGObjectOperation

+ (instancetype)operation;

- (instancetype)withType:(NSString *)type;
- (instancetype)withContent:(NSDictionary *)content;
- (PMKPromise *)post;

@end

@interface MMGFeedQuery : MMGObjectOperation

+ (instancetype)query;

- (PMKPromise *)all;

- (instancetype)notEarlierThan:(NSDate *)earliestDate;
- (instancetype)startingAt:(NSDate *)startDate;
- (instancetype)endingAt:(NSDate *)endDate;
- (instancetype)page:(NSUInteger)page;
- (instancetype)numberPerPage:(NSUInteger)numberPerPage;

@end

@interface MMGFeed : NSObject<MMGJSONSerializable>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign, readonly) unsigned long long timestamp;
@property (nonatomic, strong) NSDictionary *content;

@property (nonatomic, weak) NSDate *date;

- (PMKPromise *)post;

@end
