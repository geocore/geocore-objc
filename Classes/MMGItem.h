//
//  MMGItem.h
//  
//
//  Created by Purbo Mohamad on 6/1/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, MMGItemType) {
    kMMGItemTypeNonConsumable = 0,
    kMMGItemTypeConsumable = 1,
    kMMGItemTypeUnknown = NSUIntegerMax
};

@interface MMGItemQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;
- (PMKPromise *)lastUpdate;

@end

@interface MMGItem : MMGTaggable

@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, assign) MMGItemType type;
@property (nonatomic, strong) NSDate *validTimeStart;
@property (nonatomic, strong) NSDate *validTimeEnd;

+ (MMGItemQuery *)query;
- (PMKPromise *)setAmount:(NSInteger)amount;
- (PMKPromise *)adjustAmount:(NSInteger)amount;

@end

@interface MMGUserItem : MMGRelationship

@property (nonatomic, strong) MMGUser *user;
@property (nonatomic, strong) MMGItem *item;
@property (nonatomic, assign, readonly) NSInteger amount;
@property (nonatomic, assign, readonly) NSInteger orderNumber;

@end

@interface MMGUserItemAmountRankingRecord : NSObject<MMGJSONSerializable>

@property (nonatomic, assign, readonly) NSInteger amount;
@property (nonatomic, assign, readonly) NSUInteger rank;
@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *userName;

@end

@interface MMGUserItemAmountRanking : NSObject<MMGJSONSerializable>

@property (nonatomic, strong, readonly) NSArray *ranking;
@property (nonatomic, strong, readonly) MMGUserItemAmountRankingRecord *userRanking;

@end
