//
//  Geocore.m
//
//
//  Created by Purbo Mohamad on 5/15/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

NSString * const MMGErrorDomain = @"MMGErrorDomain";

@interface Geocore()

@property (readwrite, nonatomic, strong) NSString *baseURL;
@property (readwrite, nonatomic, strong) NSString *projectId;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSString *token;
@property (readwrite, nonatomic, strong) MMGUser *user;

@end

@implementation Geocore

+ (instancetype)instance {
    static dispatch_once_t pred;
    static id shared = nil;
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

- (instancetype) initUniqueInstance {
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] initForGeocoreFormatting];
        self.token = nil;
        // by default use plist to initialize
        [self setup];
    }
    return self;
}

+ (NSDateFormatter *)dateFormatter {
    return [Geocore instance].dateFormatter;
}

+ (NSString *)path:(NSString *)path {
    return [NSString stringWithFormat:@"%@%@", [Geocore instance].baseURL, path];
}

+ (NSString *)projectSuffix {
    NSString *projectId = [Geocore instance].projectId;
    if (projectId && [projectId hasPrefix:@"PRO-"]) {
        return [projectId substringFromIndex:4];
    }
    return nil;
}

+ (NSString *)buildIdWithProjectSuffixWithPrefix:(NSString *)prefix suffix:(NSString *)suffix {
    NSString *infix = [self projectSuffix];
    if (infix) {
        return [NSString stringWithFormat:@"%@-%@-%@", prefix, infix, suffix];
    } else {
        MMG_DEBUG(@"Project ID undefined, cannot create ID from prefix: %@, suffix: %@", prefix, suffix)
        return nil;
    }
}

- (NSString *)defaultBaseURL
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:MMG_SETKEY_BASE_URL];
}

- (NSString *)defaultProjectId
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:MMG_SETKEY_PROJECT_ID];
}

- (void)loadUserDefault {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefault stringForKey:MMG_SETKEY_USER_ID];
    
    if (userId) {
        self.user = [MMGUser new];
        self.user.id = userId;
        self.user.password = [userDefault stringForKey:MMG_SETKEY_USER_PASSWORD];
    } else {
        self.user = nil;
    }
}

- (void)saveUserDefault {
    
    if (!self.user) [NSException raise:@"Saving user default without authenticated user"
                                format:@"Saving user default without authenticated user"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.user.id forKey:MMG_SETKEY_USER_ID];
    [userDefault setObject:self.user.password forKey:MMG_SETKEY_USER_PASSWORD];
    [userDefault synchronize];
}

- (void)clearUserDefault {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:MMG_SETKEY_USER_ID];
    [userDefault removeObjectForKey:MMG_SETKEY_USER_PASSWORD];
    [userDefault synchronize];
}

- (instancetype)setup {
    self.baseURL = [self defaultBaseURL];
    self.projectId = [self defaultProjectId];
    return self;
}

- (instancetype)setupWithBaseURL:(NSString *)baseURL projectId:(NSString *)projectId {
    self.baseURL = baseURL;
    self.projectId = projectId;
    return self;
}

- (id)processResponse:(id)responseObject ofType:(Class)clazz {
    id status = [responseObject objectForKey:@"status"];
    if (![@"success" isEqualToString:status]) {
        NSError *error = nil;
        if ([@"error" isEqualToString:status]) {
            error = [NSError errorWithDomain:MMGErrorDomain code:kMMGErrorServerError userInfo:responseObject];
        } else {
            NSLog(@"[ERROR] Invalid server response: %@", responseObject);
            error = [NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidServerResponse userInfo:nil];
        }
        return error;
    } else {
        id resultObj = [responseObject objectForKey:@"result"];
        if ([resultObj isKindOfClass:[NSArray class]]) {
            // multiple result
            NSArray *resultArray = (NSArray *)resultObj;
            if (clazz) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *dict in resultArray) {
                    id<MMGJSONSerializable> obj = [clazz new];
                    [obj fromJSON:dict];
                    [array addObject:obj];
                }
                return array;
            } else {
                return resultArray;
            }
        } else {
            // singular result
            if (clazz) {
                id<MMGJSONSerializable> obj = [clazz new];
                [obj fromJSON:resultObj];
                return obj;
            } else {
                return resultObj;
            }
        }
    }
}

- (PMKPromise *)POST:(NSString *)path
                body:(NSDictionary *)body
         resultClass:(Class)clazz {
    return [self POST:path
           parameters:nil
                 body:body
          resultClass:clazz
           preProcess:nil
          postProcess:nil];
}

- (PMKPromise *)POST:(NSString *)path
          parameters:(NSDictionary *)parameters
                body:(NSDictionary *)body
         resultClass:(Class)clazz {
    return [self POST:path
           parameters:parameters
                 body:body
          resultClass:clazz
           preProcess:nil
          postProcess:nil];
}

- (PMKPromise *)POST:(NSString *)path
          parameters:(NSDictionary *)parameters
                body:(NSDictionary *)body
         resultClass:(Class)clazz
          preProcess:(id (^)(id))preProcess
         postProcess:(id (^)(id))postProcess {
    return [self requestWithMethod:@"POST"
                            toPath:path
                        parameters:parameters
                              body:body
                       resultClass:clazz
                        preProcess:preProcess
                       postProcess:postProcess];
}

- (PMKPromise *)PUT:(NSString *)path
               body:(NSDictionary *)body
        resultClass:(Class)clazz {
    return [self PUT:path
          parameters:nil
                body:body
         resultClass:clazz
          preProcess:nil
         postProcess:nil];
}

- (PMKPromise *)PUT:(NSString *)path
         parameters:(NSDictionary *)parameters
               body:(NSDictionary *)body
        resultClass:(Class)clazz {
    return [self PUT:path
          parameters:parameters
                body:body
         resultClass:clazz
          preProcess:nil
         postProcess:nil];
}

- (PMKPromise *)PUT:(NSString *)path
         parameters:(NSDictionary *)parameters
               body:(NSDictionary *)body
        resultClass:(Class)clazz
         preProcess:(id (^)(id))preProcess
        postProcess:(id (^)(id))postProcess {
    return [self requestWithMethod:@"PUT"
                            toPath:path
                        parameters:parameters
                              body:body
                       resultClass:clazz
                        preProcess:preProcess
                       postProcess:postProcess];
}

- (PMKPromise *)GET:(NSString *)path
        resultClass:(Class)clazz {
    return [self GET:path
          parameters:nil
         resultClass:clazz];
}

- (PMKPromise *)GET:(NSString *)path
         parameters:(NSDictionary *)parameters
        resultClass:(Class)clazz {
    return [self GET:path
          parameters:parameters
         resultClass:clazz
          preProcess:nil
         postProcess:nil];
}

- (PMKPromise *)GET:(NSString *)path
         parameters:(NSDictionary *)parameters
        resultClass:(Class)clazz
         preProcess:(id (^)(id))preProcess
        postProcess:(id (^)(id))postProcess {
    return [self requestWithMethod:@"GET"
                            toPath:path
                        parameters:parameters
                              body:nil
                       resultClass:clazz
                        preProcess:preProcess
                       postProcess:postProcess];
}

- (PMKPromise *)DELETE:(NSString *)path
           resultClass:(Class)clazz {
    return [self DELETE:path
             parameters:nil
            resultClass:clazz];
}

- (PMKPromise *)DELETE:(NSString *)path
            parameters:(NSDictionary *)parameters
           resultClass:(Class)clazz {
    return [self DELETE:path
             parameters:parameters
            resultClass:clazz
             preProcess:nil
            postProcess:nil];
}

- (PMKPromise *)DELETE:(NSString *)path
            parameters:(NSDictionary *)parameters
           resultClass:(Class)clazz
            preProcess:(id (^)(id))preProcess
           postProcess:(id (^)(id))postProcess {
    return [self requestWithMethod:@"DELETE"
                            toPath:path
                        parameters:parameters
                              body:nil
                       resultClass:clazz
                        preProcess:preProcess
                       postProcess:postProcess];
}

/**
 *  The ultimate Geocore HTTP request.
 *
 *  @param method      HTTP method.
 *  @param path        Path _without_ query string and Geocore base URL.
 *  @param parameters  Parameters to be appended as query string.
 *  @param body        JSON body to be sent along with the request.
 *  @param clazz       Should be classes implementing MMGJSONSerializable protocol.
 *  @param preProcess  Processing that needs to be injected before response's JSON object is converted into object of type 'clazz'.
 *  @param postProcess Processing that needs to be injected after object of type 'clazz' is created.
 *
 *  @return Promise
 */
- (PMKPromise *)requestWithMethod:(NSString *)method
                           toPath:(NSString *)path
                       parameters:(NSDictionary *)parameters
                             body:(NSDictionary *)body
                      resultClass:(Class)clazz
                       preProcess:(id (^)(id))preProcess
                      postProcess:(id (^)(id))postProcess {
    
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString *query = path;
        NSDictionary *content = nil;
        
        if (parameters && body && [parameters count] > 0 && [body count] > 0) {
            // encode parameters as query string, body as JSON
            query = [NSString stringWithFormat:@"%@?%@", path, [parameters queryString]];
            content = body;
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        } else if (parameters && [parameters count] > 0 && (!body || [body count] == 0)) {
            // parameters as body
            content = parameters;
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        } else if (body && [body count] > 0 && (!parameters || [parameters count] == 0)) {
            // body as JSON body
            content = body;
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        } else {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        
        if (self.token) {
            [manager.requestSerializer setValue:self.token forHTTPHeaderField:MMG_HTTPHEADERKEY_TOKEN];
        }
        
        MMG_DEBUG(@"[DEBUG] Sending request URL: %@", query)
        
        void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            id result = [self processResponse:preProcess ? preProcess(responseObject) : responseObject
                                       ofType:clazz];
            resolve(postProcess ? postProcess(result): result);
        };
        
        void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            resolve(error);
        };
        
        if ([@"POST" isEqualToString:method]) {
            [manager POST:[Geocore path:query] parameters:content success:success failure:failure];
        } else if ([@"PUT" isEqualToString:method]) {
            [manager PUT:[Geocore path:query] parameters:content success:success failure:failure];
        } else if ([@"GET" isEqualToString:method]) {
            [manager GET:[Geocore path:query] parameters:content success:success failure:failure];
        } else if ([@"DELETE" isEqualToString:method]) {
            [manager DELETE:[Geocore path:query] parameters:content success:success failure:failure];
        } else {
            // shouldn't happen
            NSLog(@"Unknown method: %@", method);
        }
        
    }];
}

- (PMKPromise *)login {
    [self loadUserDefault];
    if (self.user) {
        return [self loginWithUserId:_user.id password:_user.password];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidState userInfo:@{@"message": @"User has never been logged in before. No saved user info available."}]];
    }
}

- (PMKPromise *)loginWithUserId:(NSString *)userId password:(NSString *)password {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        [self POST:@"/auth"
        parameters:@{@"id" : userId,
                     @"password" : password,
                     @"project_id" : self.projectId}
              body:nil
       resultClass:[MMGGenericResult class]
        preProcess:nil
       postProcess:^NSString *(id result) {
           if ([result class] == [MMGGenericResult class]) {
               MMGGenericResult *genericResult = (MMGGenericResult *)result;
               self.token = [genericResult.json objectForKey:@"token"];
               MMG_DEBUG(@"[DEBUG] user ID: %@ logged in, receiving token: %@", userId, _token)
               return self.token;
           } else {
               MMG_DEBUG(@"[DEBUG] receiving unexpected object, possibly an error: %@", result)
               return result;
           }
       }].then(^(NSString *token) {
           return [[[MMGUser query] withId:userId] all];
       }).then(^(MMGUser *user) {
           // save user ID/password for default login
           MMG_DEBUG(@"[DEBUG] Receiving user's details for user ID: %@, saving user for default login", userId)
           self.user = user;
           self.user.password = password;
           [self saveUserDefault];
           resolve(self.user);
       }).catch(^(NSError *loginError) {
           resolve(loginError);
       });
    }];
}

- (PMKPromise *)loginWithFacebookId:(NSString *)facebookId name:(NSString *)name {
    MMGUser *facebookUser = [[MMGUser new] fromFacebookId:facebookId name:name];
    return [self loginWithUserId:facebookUser.id password:facebookUser.password];
}

- (PMKPromise *)autoLoginWithFacebookId:(NSString *)facebookId name:(NSString *)name {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        // try logging in
        [self loginWithFacebookId:facebookId name:name]
        .then(^(NSString *token) {
            resolve(token);
        })
        .catch(^(NSError *loginError) {
            if ([@"Auth.0001" isEqualToString:[loginError.userInfo objectForKey:@"code"]]) {
                // oops! try to register first
                MMGUser *fbUser = [[MMGUser new] fromFacebookId:facebookId name:name];
                [fbUser register]
                .then(^(MMGUser *registeredUser) {
                    MMG_DEBUG(@"[DEBUG] user ID: %@, registered successfully", registeredUser.id)
                    // now that the user is registered, login
                    return [self loginWithUserId:registeredUser.id password:fbUser.password];
                })
                .then(^(MMGUser *registeredUser) {
                    MMG_DEBUG(@"[DEBUG] registered user ID: %@ logged in successfully", registeredUser.id)
                    resolve(registeredUser);
                })
                .catch(^(NSError *registerError) {
                    resolve(registerError);
                });
            } else {
                // unexpected error
                resolve(loginError);
            }
        });
    }];
}

@end

@implementation NSDateFormatter(Geocore)

- (id)initForGeocoreFormatting {
    static NSLocale* en_US_POSIX = nil;
    self = [self init];
    if (en_US_POSIX == nil) {
        en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    [self setLocale:en_US_POSIX];
    [self setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [self setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return self;
}

- (NSDate *)dateFromOptionalString:(NSString *)string {
    if (string) {
        return [self dateFromString:string];
    }
    return nil;
}

@end

@implementation NSDictionary(Geocore)

- (id)optionalValueForKey:(NSString *)key withDefaultValue:(id)defaultValue {
    id value = [self objectForKey:key];
    if (value != nil && ![value isKindOfClass:[NSNull class]]) {
        return value;
    } else {
        return defaultValue;
    }
}

- (NSString *)urlEncode:(id)object {
    return [[NSString stringWithFormat:@"%@", object] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)queryString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [self urlEncode:key], [self urlEncode:value]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

@end

@implementation NSMutableDictionary(Geocore)

- (void)setOptionalValue:(id)value forKey:(id <NSCopying>)key {
    if (value) {
        [self setObject:value forKey:key];
    }
}

@end

@implementation NSString(Geocore)

- (NSString *)reverse {
    NSMutableString *reversedString = [NSMutableString string];
    NSInteger charIndex = [self length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedString appendString:[self substringWithRange:subStrRange]];
    }
    return reversedString;
}

@end

@implementation MMGPoint

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.latitude = [[jsonData optionalValueForKey:@"latitude" withDefaultValue:@(NAN)] doubleValue];
    self.longitude = [[jsonData optionalValueForKey:@"longitude" withDefaultValue:@(NAN)] doubleValue];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setOptionalValue:isnan(self.latitude) ? nil : @(self.latitude) forKey:@"latitude"];
    [dict setOptionalValue:isnan(self.longitude) ? nil : @(self.longitude) forKey:@"longitude"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end


