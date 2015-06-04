//
//  GeocorePublic.h
//
//
//  Created by Purbo Mohamad on 5/16/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PMKPromise;
@class MMGUser;

#define MMG_SETKEY_BASE_URL @"GeocoreBaseURL"
#define MMG_SETKEY_PROJECT_ID @"GeocoreProjectId"
#define MMG_SETKEY_USER_ID @"GeocoreUserId"
#define MMG_SETKEY_USER_PASSWORD @"GeocoreUserPassword"
#define MMG_HTTPHEADERKEY_TOKEN @"Geocore-Access-Token"
#define MMG_UNDEFINED_SID -1

FOUNDATION_EXPORT NSString * const MMGErrorDomain;

typedef NS_ENUM (NSInteger, MMGErrorCode) {
    kMMGErrorInvalidState,
    kMMGErrorInvalidServerResponse,
    kMMGErrorServerError,
    kMMGErrorTokenUndefined,
    kMMGErrorUnauthorizedAccess,
    kMMGErrorInvalidParameter
};

@protocol MMGJSONSerializable <NSObject>

- (instancetype)fromJSON:(NSDictionary *)jsonData;
- (NSDictionary *)toJSON;

@end

@interface MMGPoint : NSObject<MMGJSONSerializable>

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end

@interface Geocore : NSObject

// somehow this causes compile error on dynamic class allocation ([clazz new])
/*
// clue for improper use (produces compile time error)
+ (instancetype) alloc __attribute__((unavailable("alloc not available, call instance instead")));
- (instancetype) init __attribute__((unavailable("init not available, call instance instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call instance instead")));
*/

+ (instancetype)instance;
+ (NSDateFormatter *)dateFormatter;
+ (NSString *)path:(NSString *)path;
+ (NSString *)buildIdWithProjectSuffixWithPrefix:(NSString *)prefix suffix:(NSString *)suffix;

/**
 * Server base URL.
 */
@property (readonly, nonatomic, strong) NSString *baseURL;

/**
 *  Project ID assigned to the application. The value of this property
 *  is provided by MapMotion.
 */
@property (readonly, nonatomic, strong) NSString *projectId;

/**
 *  Currently logged in user, or nil if not logged in.
 */
@property (readonly, nonatomic, strong) MMGUser *user;

- (instancetype)setup;
- (instancetype)setupWithBaseURL:(NSString *)baseURL projectId:(NSString *)projectID;

- (PMKPromise *)login;
- (PMKPromise *)loginWithUserId:(NSString *)userId password:(NSString *)password;
- (PMKPromise *)loginWithFacebookId:(NSString *)facebookId name:(NSString *)name;
- (PMKPromise *)autoLoginWithFacebookId:(NSString *)facebookId name:(NSString *)name;

@end
