//
//  MMGUser.h
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (PMKPromise *)checkins;

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
- (PMKPromise *)queryCheckins;

- (PMKPromise *)logLastLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy;
- (PMKPromise *)logLatitude:(double)latitude longitude:(double)longitude accuracy:(double)accuracy;

- (PMKPromise *)pushNotificationWithDeviceToken:(NSData *)deviceToken
                              preferredLanguage:(NSString *)preferredLanguage
                                         enable:(BOOL)enable;
- (PMKPromise *)pushNotificationEnable:(BOOL)enable;

+ (PMKPromise *)connectToPeer:(MMGUser *)peer;
+ (PMKPromise *)disconnectFromPeer:(MMGUser *)peer;
+ (PMKPromise *)breakConnectionToPeer:(MMGUser *)peer permanently:(BOOL)permanently;

+ (PMKPromise *)connections;
+ (PMKPromise *)connectionToPeer:(MMGUser *)peer;
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
