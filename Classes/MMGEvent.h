//
//  MMGEvent.h
//  AnchorUp
//
//  Created by Purbo Mohamad on 5/20/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, MMGUserEventRelationshipType) {
    kMMGUserEventRelationshipTypeOrganizer = 0,
    kMMGUserEventRelationshipTypePerformer = 1,
    kMMGUserEventRelationshipTypeParticipant = 2,
    kMMGUserEventRelationshipTypeAttendant = 3,
    kMMGUserEventRelationshipTypeCustom01 = 4,
    kMMGUserEventRelationshipTypeCustom02 = 5,
    kMMGUserEventRelationshipTypeCustom03 = 6,
    kMMGUserEventRelationshipTypeCustom04 = 7,
    kMMGUserEventRelationshipTypeCustom05 = 8,
    kMMGUserEventRelationshipTypeCustom06 = 9,
    kMMGUserEventRelationshipTypeCustom07 = 10,
    kMMGUserEventRelationshipTypeCustom08 = 11,
    kMMGUserEventRelationshipTypeCustom09 = 12,
    kMMGUserEventRelationshipTypeCustom10 = 13,
    kMMGUserEventRelationshipTypeUnknown = NSUIntegerMax
};

@interface MMGEventQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;
- (PMKPromise *)lastUpdate;

@end

@interface MMGEvent : MMGTaggable

@property (nonatomic, strong) NSDate *timeStart;
@property (nonatomic, strong) NSDate *timeEnd;

+ (MMGEventQuery *)query;

@end

@interface MMGUserEvent : MMGRelationship

@property (nonatomic, strong) MMGUser *user;
@property (nonatomic, strong) MMGEvent *event;
@property (nonatomic, assign) MMGUserEventRelationshipType relationshipType;

+ (MMGUserEventRelationshipType)typeFromString:(NSString *)typeAsString;
+ (NSString *)stringFromType:(MMGUserEventRelationshipType)type;

@end