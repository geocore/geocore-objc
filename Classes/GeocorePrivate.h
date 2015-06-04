//
//  GeocorePrivate.h
//
//
//  Created by Purbo Mohamad on 5/17/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <PromiseKit/PromiseKit.h>

#ifdef DEBUG
#   define MMG_DEBUG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define MMG_DEBUG(...)
#endif

@interface NSDateFormatter(Geocore)

- (id)initForGeocoreFormatting;
- (NSDate *)dateFromOptionalString:(NSString *)string;

@end

@interface NSDictionary(Geocore)

- (id)optionalValueForKey:(NSString *)key withDefaultValue:(id)defaultValue;
- (NSString *)queryString;

@end

@interface NSMutableDictionary(Geocore)

- (void)setOptionalValue:(id)anObject forKey:(id <NSCopying>)aKey;

@end

@interface NSString(Geocore)

- (NSString *)reverse;

@end

@interface Geocore(Private)

- (PMKPromise *)POST:(NSString *)path
                body:(NSDictionary *)body
         resultClass:(Class)clazz;

- (PMKPromise *)POST:(NSString *)path
          parameters:(NSDictionary *)parameters
                body:(NSDictionary *)body
         resultClass:(Class)clazz;

- (PMKPromise *)POST:(NSString *)path
          parameters:(NSDictionary *)parameters
                body:(NSDictionary *)body
         resultClass:(Class)clazz
          preProcess:(id (^)(id))preProcess
         postProcess:(id (^)(id))postProcess;

- (PMKPromise *)PUT:(NSString *)path
               body:(NSDictionary *)body
        resultClass:(Class)clazz;

- (PMKPromise *)PUT:(NSString *)path
         parameters:(NSDictionary *)parameters
               body:(NSDictionary *)body
        resultClass:(Class)clazz;

- (PMKPromise *)PUT:(NSString *)path
         parameters:(NSDictionary *)parameters
               body:(NSDictionary *)body
        resultClass:(Class)clazz
         preProcess:(id (^)(id))preProcess
        postProcess:(id (^)(id))postProcess;

- (PMKPromise *)GET:(NSString *)path
        resultClass:(Class)clazz;

- (PMKPromise *)GET:(NSString *)path
         parameters:(NSDictionary *)parameters
        resultClass:(Class)clazz;

- (PMKPromise *)GET:(NSString *)path
         parameters:(NSDictionary *)parameters
        resultClass:(Class)clazz
         preProcess:(id (^)(id))preProcess
        postProcess:(id (^)(id))postProcess;

- (PMKPromise *)DELETE:(NSString *)path
           resultClass:(Class)clazz;

- (PMKPromise *)DELETE:(NSString *)path
            parameters:(NSDictionary *)parameters
           resultClass:(Class)clazz;

- (PMKPromise *)DELETE:(NSString *)path
            parameters:(NSDictionary *)parameters
           resultClass:(Class)clazz
            preProcess:(id (^)(id))preProcess
           postProcess:(id (^)(id))postProcess;

@end