//
//  MMGItem.m
//  
//
//  Created by Purbo Mohamad on 6/1/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@implementation MMGItemQuery

+ (instancetype)query {
    return [MMGItemQuery new];
}

- (PMKPromise *)all {
    return [[Geocore instance] GET:[self buildPath:@"/items"]
                        parameters:[super buildQueryParameters]
                       resultClass:[MMGItem class]];
}

@end

@implementation MMGItem

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.shortName = [jsonData optionalValueForKey:@"shortName" withDefaultValue:nil];
    self.shortDesc = [jsonData optionalValueForKey:@"shortDescription" withDefaultValue:nil];
    self.type = [MMGItem typeFromString:[jsonData optionalValueForKey:@"type" withDefaultValue:@""]];
    self.validTimeStart = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"validTimeStart" withDefaultValue:nil]];
    self.validTimeEnd = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"validTimeEnd" withDefaultValue:nil]];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:self.shortName forKey:@"shortName"];
    [dict setOptionalValue:self.shortDesc forKey:@"shortDescription"];
    [dict setOptionalValue:[MMGItem stringFromType:self.type] forKey:@"type"];
    // TODO: should serialize validTimeStart, validTimeEnd
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (MMGItemType)typeFromString:(NSString *)typeAsString {
    if ([@"NON_CONSUMABLE" isEqualToString:typeAsString]) {
        return kMMGItemTypeNonConsumable;
    } else if ([@"CONSUMABLE" isEqualToString:typeAsString]) {
        return kMMGItemTypeConsumable;
    } else {
        return kMMGItemTypeUnknown;
    }
}

+ (NSString *)stringFromType:(MMGItemType)type {
    if (type == kMMGItemTypeNonConsumable) {
        return @"NON_CONSUMABLE";
    } else if (type == kMMGItemTypeConsumable) {
        return @"CONSUMABLE";
    } else {
        return nil;
    }
}

+ (MMGItemQuery *)query {
    return [MMGItemQuery query];
}

- (PMKPromise *)adjustAmount:(NSInteger)amount {
    return [[Geocore instance] POST:amount > 0 ?
                                    [NSString stringWithFormat:@"/users/%@/items/%@/amount/+%ld", [Geocore instance].user.id, self.id, (long)amount] :
                                    [NSString stringWithFormat:@"/users/%@/items/%@/amount/-%ld", [Geocore instance].user.id, self.id, (long)amount]
                               body:nil
                        resultClass:[MMGUserItem class]];
}

- (PMKPromise *)setAmount:(NSInteger)amount {
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/users/%@/items/%@/amount/%ld", [Geocore instance].user.id, self.id, (long)amount]
                               body:nil
                        resultClass:[MMGUserItem class]];
}

@end

@interface MMGUserItem()

@property (nonatomic, assign, readwrite) NSInteger amount;
@property (nonatomic, assign, readwrite) NSInteger orderNumber;

@end

@implementation MMGUserItem

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    NSDictionary *pk = [jsonData optionalValueForKey:@"pk" withDefaultValue:@{}];
    NSDictionary *userDict = [pk optionalValueForKey:@"user" withDefaultValue:nil];
    if (userDict) {
        self.user = [[MMGUser new] fromJSON:userDict];
    }
    NSDictionary *itemDict = [pk optionalValueForKey:@"item" withDefaultValue:nil];
    if (itemDict) {
        self.item = [[MMGItem new] fromJSON:itemDict];
    }
    self.amount = [[jsonData optionalValueForKey:@"amount" withDefaultValue:@(0)] integerValue];
    self.orderNumber = [[jsonData optionalValueForKey:@"orderNumber" withDefaultValue:@(0)] integerValue];
    self.updateTime = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"updateTime" withDefaultValue:nil]];
    return self;
}

@end