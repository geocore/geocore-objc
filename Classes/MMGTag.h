//
//  MMGTag.h
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, MMGTagType) {
    kMMGTagTypeSystem = 0,
    kMMGTagTypeUser = 1,
    kMMGTagTypeUnknown = NSUIntegerMax
};

@interface MMGTaggableOperation : MMGObjectOperation

- (instancetype)tagWithIds:(NSArray *)tagIds;
- (instancetype)tagWithNames:(NSArray *)tagNames;
- (instancetype)untagWithIds:(NSArray *)tagIds;
- (instancetype)untagWithNames:(NSArray *)tagNames;

@end

@interface MMGTaggableQuery : MMGObjectQuery

- (instancetype)withTagDetails;
- (instancetype)withTagIds:(NSArray *)tagIds;
- (instancetype)withTagNames:(NSArray *)tagNames;

@end

@interface MMGTagQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;
- (PMKPromise *)lastUpdate;

@end

@interface MMGTaggable : MMGObject

@property (readonly, nonatomic, strong) NSArray *tags;

@end

@interface MMGTag : MMGTaggable

@property (nonatomic, assign) MMGTagType type;

+ (MMGTagType)typeFromString:(NSString *)typeAsString;
+ (NSString *)stringFromType:(MMGTagType)type;
+ (MMGTagQuery *)query;

@end
