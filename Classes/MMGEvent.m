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

- (PMKPromise *)lastUpdate {
    return [super lastUpdateForServicePath:@"/events"];
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

@implementation MMGUserEvent

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    NSDictionary *pk = [jsonData optionalValueForKey:@"pk" withDefaultValue:@{}];
    NSDictionary *userDict = [pk optionalValueForKey:@"user" withDefaultValue:nil];
    if (userDict) {
        self.user = [[MMGUser new] fromJSON:userDict];
    }
    NSDictionary *eventDict = [pk optionalValueForKey:@"event" withDefaultValue:nil];
    if (eventDict) {
        self.event = [[MMGEvent new] fromJSON:eventDict];
    }
    self.relationshipType = [MMGUserEvent typeFromString:[jsonData optionalValueForKey:@"relationship" withDefaultValue:@""]];
    return self;
}

+ (MMGUserEventRelationshipType)typeFromString:(NSString *)typeAsString {
    if ([@"ORGANIZER" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeOrganizer;
    } else if ([@"PERFORMER" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypePerformer;
    } else if ([@"PARTICIPANT" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeParticipant;
    } else if ([@"ATTENDANT" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeAttendant;
    } else if ([@"CUSTOM01" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom01;
    } else if ([@"CUSTOM02" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom02;
    } else if ([@"CUSTOM03" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom03;
    } else if ([@"CUSTOM04" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom04;
    } else if ([@"CUSTOM05" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom05;
    } else if ([@"CUSTOM06" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom06;
    } else if ([@"CUSTOM07" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom07;
    } else if ([@"CUSTOM08" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom08;
    } else if ([@"CUSTOM09" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom09;
    } else if ([@"CUSTOM10" isEqualToString:typeAsString]) {
        return kMMGUserEventRelationshipTypeCustom10;
    } else {
        return kMMGUserEventRelationshipTypeUnknown;
    }
}

+ (NSString *)stringFromType:(MMGUserEventRelationshipType)type {
    if (type == kMMGUserEventRelationshipTypeOrganizer) {
        return @"ORGANIZER";
    } else if (type == kMMGUserEventRelationshipTypePerformer) {
        return @"PERFORMER";
    } else if (type == kMMGUserEventRelationshipTypeParticipant) {
        return @"PARTICIPANT";
    } else if (type == kMMGUserEventRelationshipTypeAttendant) {
        return @"ATTENDANT";
    } else if (type == kMMGUserEventRelationshipTypeCustom01) {
        return @"CUSTOM01";
    } else if (type == kMMGUserEventRelationshipTypeCustom02) {
        return @"CUSTOM02";
    } else if (type == kMMGUserEventRelationshipTypeCustom03) {
        return @"CUSTOM03";
    } else if (type == kMMGUserEventRelationshipTypeCustom04) {
        return @"CUSTOM04";
    } else if (type == kMMGUserEventRelationshipTypeCustom05) {
        return @"CUSTOM05";
    } else if (type == kMMGUserEventRelationshipTypeCustom06) {
        return @"CUSTOM06";
    } else if (type == kMMGUserEventRelationshipTypeCustom07) {
        return @"CUSTOM07";
    } else if (type == kMMGUserEventRelationshipTypeCustom08) {
        return @"CUSTOM08";
    } else if (type == kMMGUserEventRelationshipTypeCustom09) {
        return @"CUSTOM09";
    } else if (type == kMMGUserEventRelationshipTypeCustom10) {
        return @"CUSTOM10";
    } else {
        return nil;
    }
}

@end
