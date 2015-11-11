//
//  MMGTag.m
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@interface MMGTaggableOperation()

@property (nonatomic, strong) NSArray *tagIdsToAdd;
@property (nonatomic, strong) NSArray *tagIdsToDelete;
@property (nonatomic, strong) NSArray *tagNamesToAdd;
@property (nonatomic, strong) NSArray *tagNamesToDelete;

@end


@interface MMGTaggableQuery()

@property (nonatomic, assign) BOOL tagDetails;
@property (nonatomic, strong) NSArray *tagIds;
@property (nonatomic, strong) NSArray *tagNames;

@end

@interface MMGTaggable()

@property (readwrite, nonatomic, strong) NSArray *tags;

@end

@implementation MMGTaggableOperation

- (instancetype)tagWithIds:(NSArray *)tagIds {
    self.tagIdsToAdd = tagIds;
    return self;
}

- (instancetype)tagWithNames:(NSArray *)tagNames {
    self.tagNamesToAdd = tagNames;
    return self;
}

- (instancetype)untagWithIds:(NSArray *)tagIds {
    self.tagIdsToDelete = tagIds;
    return self;
}

- (instancetype)untagWithNames:(NSArray *)tagNames {
    self.tagNamesToDelete = tagNames;
    return self;
}

- (NSDictionary *)buildQueryParameters {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super buildQueryParameters]];
    if (self.tagIdsToAdd && [_tagIdsToAdd count] > 0) {
        [dict setObject:[_tagIdsToAdd componentsJoinedByString:@","] forKey:@"tag_ids"];
    }
    if (self.tagNamesToAdd && [_tagNamesToAdd count] > 0) {
        [dict setObject:[_tagNamesToAdd componentsJoinedByString:@","] forKey:@"tag_names"];
    }
    if (self.tagIdsToDelete && [_tagIdsToDelete count] > 0) {
        [dict setObject:[_tagIdsToDelete componentsJoinedByString:@","] forKey:@"del_tag_ids"];
    }
    if (self.tagNamesToDelete && [_tagNamesToDelete count] > 0) {
        [dict setObject:[_tagNamesToDelete componentsJoinedByString:@","] forKey:@"del_tag_names"];
    }
    return dict;
}

@end

@implementation MMGTaggableQuery

- (instancetype)withTagDetails {
    self.tagDetails = YES;
    return self;
}

- (instancetype)withTagIds:(NSArray *)tagIds {
    self.tagIds = tagIds;
    return self;
}

- (instancetype)withTagNames:(NSArray *)tagNames {
    self.tagNames = tagNames;
    return self;
}

- (NSDictionary *)buildQueryParameters {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super buildQueryParameters]];
    if (self.tagDetails) {
        [dict setObject:@"true" forKey:@"tag_detail"];
    }
    return dict;
}

@end

@implementation MMGTagQuery

+ (instancetype)query {
    return [MMGTagQuery new];
}

- (PMKPromise *)all {
    return [[Geocore instance] GET:[self buildPath:@"/tags"]
                        parameters:[super buildQueryParameters]
                       resultClass:[MMGTag class]];
}

- (PMKPromise *)lastUpdate {
    return [super lastUpdateForServicePath:@"/tags"];
}

@end

@implementation MMGTaggable

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    NSMutableArray *tags = [NSMutableArray array];
    NSArray *tagsJSON = [jsonData optionalValueForKey:@"tags" withDefaultValue:@[]];
    for (NSDictionary *tagJSON in tagsJSON) {
        [tags addObject:[[MMGTag new] fromJSON:tagJSON]];
    }
    self.tags = tags;
    return self;
}

@end

@implementation MMGTag

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.type = [MMGTag typeFromString:[jsonData optionalValueForKey:@"type" withDefaultValue:@""]];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:[MMGTag stringFromType:self.type] forKey:@"type"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (MMGTagType)typeFromString:(NSString *)typeAsString {
    if ([@"SYSTEM_TAG" isEqualToString:typeAsString]) {
        return kMMGTagTypeSystem;
    } else if ([@"USER_TAG" isEqualToString:typeAsString]) {
        return kMMGTagTypeUser;
    } else {
        return kMMGTagTypeUnknown;
    }
}

+ (NSString *)stringFromType:(MMGTagType)type {
    if (type == kMMGTagTypeSystem) {
        return @"SYSTEM_TAG";
    } else if (type == kMMGTagTypeUser) {
        return @"USER_TAG";
    } else {
        return nil;
    }
}

+ (MMGTagQuery *)query {
    return [MMGTagQuery query];
}

@end
