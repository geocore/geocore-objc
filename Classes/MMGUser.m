//
//  MMGUser.m
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@interface MMGUser()

@property (readwrite, nonatomic, strong) NSDate *lastLocationTime;
@property (readwrite, nonatomic, strong) MMGPoint *lastLocation;

@end

@interface MMGUserEventOperation()

@property (nonatomic, assign) MMGUserEventRelationshipType relationshipType;

@end

@implementation MMGUserTagOperation

+ (instancetype)operation {
    return [MMGUserTagOperation new];
}

- (PMKPromise *)update {
    NSString *path = [self buildPath:@"/users" withIdForSubPath:@"/tags"];
    if (path) {
        return [[Geocore instance] POST:path
                             parameters:[super buildQueryParameters]
                                   body:nil
                            resultClass:[MMGTag class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

@end


@implementation MMGUserQuery

+ (instancetype)query {
    return [MMGUserQuery new];
}

- (PMKPromise *)all {
    return [[Geocore instance] GET:[self buildPath:@"/users"]
                        parameters:[super buildQueryParameters]
                       resultClass:[MMGUser class]];
}

- (PMKPromise *)tags {
    NSString *path = [self buildPath:@"/users" withIdForSubPath:@"/tags"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:nil
                           resultClass:[MMGTag class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)items {
    NSString *path = [self buildPath:@"/users" withIdForSubPath:@"/items"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:@{@"output_format": @"json.relationship"} // TODO: should support both formats
                           resultClass:[MMGUserItem class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)events {
    return [[[MMGRelationshipOperation new]
                                       withObject1Id:self.id]
                                       getRelationshipOfType:[MMGUserEvent class] withServicePath:@"/users" idForSubPath:@"/events"];
}

- (PMKPromise *)checkins {
    NSString *path = [self buildPath:@"/users" withIdForSubPath:@"/checkins"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:@{@"num": @(0)} // TODO: implement detail constraints
                           resultClass:[MMGPlaceCheckin class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)get {
    return [self getObjectOfType:[MMGUser class] withServicePath:@"/users"];
}

@end

@implementation MMGUserEventOperation

- (instancetype)withUser:(MMGUser *)user {
    return [self withObject1Id:user.id];
}

- (instancetype)withEvent:(MMGEvent *)event {
    return [self withObject2Id:event.id];
}

- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath {
    if (self.id1 && self.id2) {
        return [NSString stringWithFormat:@"%@/%@%@/%@/%@", servicePath, self.id1, subPath, self.id2, [MMGUserEvent stringFromType:self.relationshipType]];
    } else {
        return nil;
    }
}

- (PMKPromise *)postWithRelationshipType:(MMGUserEventRelationshipType)relationshipType {
    self.relationshipType = relationshipType;
    return [self postRelationshipOfType:[MMGUserEvent class] withServicePath:@"/users" idForSubPath:@"/events"];
}

- (PMKPromise *)getWithRelationshipType:(MMGUserEventRelationshipType)relationshipType {
    self.relationshipType = relationshipType;
    return [self getRelationshipOfType:[MMGUserEvent class] withServicePath:@"/users" idForSubPath:@"/events"];
}

- (PMKPromise *)organize {
    return [self postWithRelationshipType:kMMGUserEventRelationshipTypeOrganizer];
}

- (PMKPromise *)perform {
    return [self postWithRelationshipType:kMMGUserEventRelationshipTypePerformer];
}

- (PMKPromise *)participate {
    return [self postWithRelationshipType:kMMGUserEventRelationshipTypeParticipant];
}

- (PMKPromise *)attend {
    return [self postWithRelationshipType:kMMGUserEventRelationshipTypeAttendant];
}

- (PMKPromise *)organization {
    return [self getWithRelationshipType:kMMGUserEventRelationshipTypeOrganizer];
}

- (PMKPromise *)performance {
    return [self getWithRelationshipType:kMMGUserEventRelationshipTypePerformer];
}

- (PMKPromise *)participation {
    return [self getWithRelationshipType:kMMGUserEventRelationshipTypeParticipant];
}

- (PMKPromise *)attendance {
    return [self getWithRelationshipType:kMMGUserEventRelationshipTypeAttendant];
}

- (PMKPromise *)leaveAs:(MMGUserEventRelationshipType)relationshipType {
    self.relationshipType = relationshipType;
    if (self.id1 && self.id2) {
        return [[Geocore instance] DELETE:[self buildPath:@"/users" withIdForSubPath:@"/events"]
                               parameters:nil
                              resultClass:[MMGUserEvent class]];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

@end



@implementation MMGUser

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    self.email = [jsonData optionalValueForKey:@"email" withDefaultValue:nil];
    self.lastLocationTime = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"lastLocationTime" withDefaultValue:nil]];
    NSDictionary *lastLocationJSON = [jsonData optionalValueForKey:@"lastLocation" withDefaultValue:nil];
    if (lastLocationJSON) {
        self.lastLocation = [[MMGPoint new] fromJSON:lastLocationJSON];
    }
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super toJSON]];
    [dict setOptionalValue:self.password forKey:@"password"];
    [dict setOptionalValue:self.email forKey:@"email"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (instancetype)fromFacebookId:(NSString *)facebookId name:(NSString *)name {
    self.id = [Geocore buildIdWithProjectSuffixWithPrefix:@"USE" suffix:facebookId];
    self.name = name;
    self.password = [facebookId reverse];
    [self setCustomDataValue:facebookId forKey:MMG_SETKEY_USER_FB_ID];
    [self setCustomDataValue:name forKey:MMG_SETKEY_USER_FB_NAME];
    return self;
}

+ (NSString *)userIdWithSuffix:(NSString *)suffix {
    if ([Geocore instance].projectId) {
        return [Geocore buildIdWithProjectSuffixWithPrefix:@"USE" suffix:suffix];
    } else {
        return suffix;
    }
}

+ (NSString *)defaultId {
    return [self userIdWithSuffix:[self defaultName]];
}

+ (NSString *)defaultName {
#if (TARGET_IPHONE_SIMULATOR)
    return @"IOS_SIMULATOR";
#else
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#endif
}

+ (NSString *)defaultEmail {
    return [NSString stringWithFormat:@"%@@geocore.jp", [self defaultName]];
}

+ (NSString *)defaultPassword {
    return [[self defaultId] reverse];
}

+ (instancetype)defaultUser {
    MMGUser *user = [MMGUser new];
    user.id = [self defaultId];
    user.name = [self defaultName];
    user.email = [self defaultEmail];
    user.password = [self defaultPassword];
    return user;
}

+ (MMGUserQuery *)query {
    return [MMGUserQuery query];
}

- (PMKPromise *)save {
    return [[Geocore instance] POST:self.id ? [NSString stringWithFormat:@"/users/%@", self.id] : @"/users"
                               body:[self toJSON]
                        resultClass:[MMGUser class]];
}

- (MMGUserTagOperation *)tagOperation {
    return [[MMGUserTagOperation operation] withId:self.id];
}

- (PMKPromise *)queryTags {
    return [[[MMGUserQuery query] withId:self.id] tags];
}

- (PMKPromise *)queryItems {
    return [[[MMGUserQuery query] withId:self.id] items];
}

- (PMKPromise *)queryEvents {
    return [[[MMGUserQuery query] withId:self.id] events];
}

- (PMKPromise *)queryCheckins {
    return [[[MMGUserQuery query] withId:self.id] checkins];
}

- (PMKPromise *)logLastLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy {
    MMGTrackPoint *trackPoint = [[MMGTrackPoint alloc] initWithId:self.id
                                                         latitude:latitude
                                                        longitude:longitude
                                                         accuracy:accuracy
                                                             date:[NSDate date]
                                                             memo:nil];
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/users/%@/locationlogs?retain=false", self.id] body:[trackPoint toJSON] resultClass:[MMGTrackPoint class]];
}

- (PMKPromise *)logLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy {
    MMGTrackPoint *trackPoint = [[MMGTrackPoint alloc] initWithId:self.id
                                                         latitude:latitude
                                                        longitude:longitude
                                                         accuracy:accuracy
                                                             date:[NSDate date]
                                                             memo:nil];
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/users/%@/locationlogs", self.id] body:[trackPoint toJSON] resultClass:[MMGTrackPoint class]];
}

- (PMKPromise *)register {
    NSDictionary *params = @{@"project_id": [Geocore instance].projectId};
    return [[Geocore instance] POST:@"/register"
                         parameters:params // TODO: should pass groups & tags
                               body:[self toJSON]
                        resultClass:[MMGUser class]];
}

- (PMKPromise *)pushNotificationWithDeviceToken:(NSData *)deviceToken
                              preferredLanguage:(NSString *)preferredLanguage
                                         enable:(BOOL)enable {
    
    BOOL tokenUpdated = ![[self.customData objectForKey:MMG_SETKEY_USER_PUSH_TOKEN] isEqualToString:[deviceToken description]];
    BOOL langUpdated = preferredLanguage && ![preferredLanguage isEqualToString:[self.customData objectForKey:MMG_SETKEY_USER_PUSH_LANG]];
    BOOL enabledUpdated = ![[self.customData objectForKey:MMG_SETKEY_USER_PUSH_ENABLED] isEqualToString:enable?@"true":@"false"];
    
    if (tokenUpdated || langUpdated || enabledUpdated) {
        [self setCustomDataValue:[deviceToken description] forKey:MMG_SETKEY_USER_PUSH_TOKEN];
        [self setCustomDataValue:enable?@"true":@"false" forKey:MMG_SETKEY_USER_PUSH_ENABLED];
        if (preferredLanguage) {
            [self setCustomDataValue:preferredLanguage forKey:MMG_SETKEY_USER_PUSH_LANG];
        }
        return [self save];
    } else {
        return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
            resolve(self);
        }];
    }
}

- (PMKPromise *)pushNotificationEnable:(BOOL)enable {
    BOOL enabledUpdated = ![[self.customData objectForKey:MMG_SETKEY_USER_PUSH_ENABLED] isEqualToString:enable?@"true":@"false"];
    if (enabledUpdated) {
        [self setCustomDataValue:enable?@"true":@"false" forKey:MMG_SETKEY_USER_PUSH_ENABLED];
        return [self save];
    } else {
        return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
            resolve(self);
        }];
    }
}

- (PMKPromise *)organizeAnEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData {
    return [[[[[MMGUserEventOperation new] withUser:self] withEvent:event] withCustomData:customData] organize];
}

- (PMKPromise *)performAtEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData {
    return [[[[[MMGUserEventOperation new] withUser:self] withEvent:event] withCustomData:customData] perform];
}

- (PMKPromise *)participateInEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData {
    return [[[[[MMGUserEventOperation new] withUser:self] withEvent:event] withCustomData:customData] participate];
}

- (PMKPromise *)attendAnEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData {
    return [[[[[MMGUserEventOperation new] withUser:self] withEvent:event] withCustomData:customData] attend];
}

- (PMKPromise *)organizationOfEvent:(MMGEvent *)event {
    return [[[[MMGUserEventOperation new] withUser:self] withEvent:event] organization];
}

- (PMKPromise *)performanceAtEvent:(MMGEvent *)event {
    return [[[[MMGUserEventOperation new] withUser:self] withEvent:event] performance];
}

- (PMKPromise *)participationInEvent:(MMGEvent *)event {
    return [[[[MMGUserEventOperation new] withUser:self] withEvent:event] participation];
}

- (PMKPromise *)attendanceAtEvent:(MMGEvent *)event {
    return [[[[MMGUserEventOperation new] withUser:self] withEvent:event] attendance];
}

- (PMKPromise *)leaveEvent:(MMGEvent *)event as:(MMGUserEventRelationshipType)relationshipType {
    return [[[[MMGUserEventOperation new] withUser:self] withEvent:event] leaveAs:relationshipType];
}


+ (PMKPromise *)connectToPeer:(MMGUser *)peer {
    return [[Geocore instance] POST:[NSString stringWithFormat:@"/users/connections/%@",peer.id]
                               body:nil
                        resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)disconnectFromPeer:(MMGUser *)peer {
    return [[Geocore instance] DELETE:[NSString stringWithFormat:@"/users/connections/%@",peer.id]
                           parameters:nil
                          resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)breakConnectionToPeer:(MMGUser *)peer permanently:(BOOL)permanently {
    NSDictionary *params = nil;
    if (permanently) {
        params = @{@"delete": @"true"};
    }
    return [[Geocore instance] DELETE:[NSString stringWithFormat:@"/users/connections/mutual/%@",peer.id]
                           parameters:params
                          resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)connections {
    return [[Geocore instance] GET:@"/users/relationships"
                        parameters:nil
                       resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)connectionToPeer:(MMGUser *)peer {
    return [[Geocore instance] GET:[NSString stringWithFormat:@"/users/relationships/%@", peer.id]
                        parameters:nil
                       resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)connectionToPeerWithId:(NSString *)peerId {
    return [[Geocore instance] GET:[NSString stringWithFormat:@"/users/relationships/%@", peerId]
                        parameters:nil
                       resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)acceptedConnections {
    return [[Geocore instance] GET:@"/users/relationships"
                        parameters:@{@"accepted": @"true", @"accepted_by": @"true"}
                       resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)pendingConnections {
    return [[Geocore instance] GET:@"/users/relationships"
                        parameters:@{@"accepted": @"false", @"accepted_by": @"true"}
                       resultClass:[MMGUserConnection class]];
}

+ (PMKPromise *)waitingConnections {
    return [[Geocore instance] GET:@"/users/relationships"
                        parameters:@{@"accepted": @"true", @"accepted_by": @"false"}
                       resultClass:[MMGUserConnection class]];
}

@end

@implementation MMGUserConnection

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    [super fromJSON:jsonData];
    
    MMGUser *user1 = [[MMGUser new] fromJSON:[jsonData valueForKey:@"user1"]];
    MMGUser *user2 = [[MMGUser new] fromJSON:[jsonData valueForKey:@"user2"]];
    
    NSString *currentUserId = [Geocore instance].user.id;
    if ([currentUserId isEqualToString:user1.id]) {
        self.peer = user2;
        self.accepted = [[jsonData valueForKey:@"acceptedByUser1"] boolValue];
        self.peerAccepted = [[jsonData valueForKey:@"acceptedByUser2"] boolValue];
    } else if ([currentUserId isEqualToString:user2.id]) {
        self.peer = user1;
        self.accepted = [[jsonData valueForKey:@"acceptedByUser2"] boolValue];
        self.peerAccepted = [[jsonData valueForKey:@"acceptedByUser1"] boolValue];
    } else {
        NSLog(@"[ERROR] Unexpected user connection data received. No user matches currently logged in user");
    }
    
    return self;
}

- (PMKPromise *)disconnect {
    return [MMGUser breakConnectionToPeer:_peer permanently:YES];
}

- (PMKPromise *)accept {
    return [MMGUser connectToPeer:_peer];
}

- (PMKPromise *)reject {
    return [MMGUser disconnectFromPeer:_peer];
}

@end

