//
//  MMGUser.h
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMGEvent.h"
#import "MMGItem.h"

#define MMG_SETKEY_USER_FB_ID @"sns.fb.id"
#define MMG_SETKEY_USER_FB_NAME @"sns.fb.name"
#define MMG_SETKEY_USER_PUSH_TOKEN @"push.ios.token"
#define MMG_SETKEY_USER_PUSH_LANG @"push.ios.lang"
#define MMG_SETKEY_USER_PUSH_ENABLED @"push.enabled"

@interface MMGUserTagOperation : MMGTaggableOperation

+ (instancetype)operation;
- (PMKPromise *)update;

@end

@interface MMGUserQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;
- (PMKPromise *)tags;
- (PMKPromise *)items;
- (PMKPromise *)events;
- (PMKPromise *)numberOfEventsWithCustomDataKey:(NSString *)key value:(NSString *)value;
- (PMKPromise *)checkins;

@end

@interface MMGUserEventOperation : MMGRelationshipOperation

- (instancetype)withUser:(MMGUser *)user;
- (instancetype)withEvent:(MMGEvent *)event;

- (PMKPromise *)organize;
- (PMKPromise *)perform;
- (PMKPromise *)participate;
- (PMKPromise *)attend;

- (PMKPromise *)organization;
- (PMKPromise *)performance;
- (PMKPromise *)participation;
- (PMKPromise *)attendance;

- (PMKPromise *)leaveAs:(MMGUserEventRelationshipType)relationshipType;

@end

@interface MMGUserItemOperation : MMGRelationshipOperation

- (instancetype)withUser:(MMGUser *)user;
- (instancetype)withItem:(MMGItem *)item;

- (PMKPromise *)ranking;

@end

@interface MMGUser : MMGTaggable

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (readonly, nonatomic, strong) NSDate *lastLocationTime;
@property (readonly, nonatomic, strong) MMGPoint *lastLocation;

+ (NSString *)defaultId;
+ (NSString *)defaultName;
+ (NSString *)defaultEmail;
+ (NSString *)defaultPassword;
+ (instancetype)defaultUser;

- (instancetype)fromFacebookId:(NSString *)facebookId name:(NSString *)name;

+ (MMGUserQuery *)query;

- (PMKPromise *)register;
- (PMKPromise *)save;
- (MMGUserTagOperation *)tagOperation;
- (PMKPromise *)queryTags;
- (PMKPromise *)queryItems;
- (PMKPromise *)queryEvents;
- (PMKPromise *)countEventsWithCustomDataKey:(NSString *)key value:(NSString *)value;
- (PMKPromise *)queryCheckins;

- (PMKPromise *)logLastLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy;
- (PMKPromise *)logLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy;

- (PMKPromise *)pushNotificationWithDeviceToken:(NSData *)deviceToken
                              preferredLanguage:(NSString *)preferredLanguage
                                         enable:(BOOL)enable;
- (PMKPromise *)pushNotificationEnable:(BOOL)enable;

- (PMKPromise *)organizeAnEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData;
- (PMKPromise *)performAtEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData;
- (PMKPromise *)participateInEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData;
- (PMKPromise *)attendAnEvent:(MMGEvent *)event withCustomData:(NSDictionary *)customData;

- (PMKPromise *)organizationOfEvent:(MMGEvent *)event;
- (PMKPromise *)performanceAtEvent:(MMGEvent *)event;
- (PMKPromise *)participationInEvent:(MMGEvent *)event;
- (PMKPromise *)attendanceAtEvent:(MMGEvent *)event;

- (PMKPromise *)leaveEvent:(MMGEvent *)event as:(MMGUserEventRelationshipType)relationshipType;

+ (PMKPromise *)connectToPeer:(MMGUser *)peer;
+ (PMKPromise *)disconnectFromPeer:(MMGUser *)peer;
+ (PMKPromise *)breakConnectionToPeer:(MMGUser *)peer permanently:(BOOL)permanently;

+ (PMKPromise *)connections;
+ (PMKPromise *)connectionToPeer:(MMGUser *)peer;
+ (PMKPromise *)connectionToPeerWithId:(NSString *)peerId;
+ (PMKPromise *)acceptedConnections;
+ (PMKPromise *)pendingConnections;
+ (PMKPromise *)waitingConnections;

@end

@interface MMGUserConnection : MMGRelationship

@property (nonatomic, strong) MMGUser *peer;
@property (nonatomic, assign) BOOL accepted;
@property (nonatomic, assign) BOOL peerAccepted;

- (PMKPromise *)disconnect;
- (PMKPromise *)accept;
- (PMKPromise *)reject;

@end
