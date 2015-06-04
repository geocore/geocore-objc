//
//  MMGObject.h
//  
//
//  Created by Purbo Mohamad on 5/16/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGObjectOperation : NSObject

- (instancetype)withId:(NSString *)id;

- (NSString *)buildPath:(NSString *)servicePath;
- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath;
- (NSDictionary *)buildQueryParameters;

@end

@interface MMGObjectQuery : MMGObjectOperation

+ (instancetype)query;

- (instancetype)withName:(NSString *)name;
- (instancetype)updatedAfter:(NSDate *)date;
- (instancetype)havingCustomDataValue:(NSString *)value forKey:(NSString *)key;
- (instancetype)page:(NSUInteger)page;
- (instancetype)numberPerPage:(NSUInteger)numberPerPage;

@end

@interface MMGObjectBinaryOperation : MMGObjectOperation

+ (instancetype)operation;

- (instancetype)withKey:(NSString *)key;
- (PMKPromise *)allKeys;
- (PMKPromise *)url;
- (PMKPromise *)image;

@end

@interface MMGObject : NSObject<MMGJSONSerializable>

@property (readonly, nonatomic, assign) long sid;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (readonly, nonatomic, strong) NSDate *createTime;
@property (readonly, nonatomic, strong) NSDate *updateTime;
@property (readonly, nonatomic, assign) long upvotes;
@property (readonly, nonatomic, assign) long downvotes;
@property (readonly, nonatomic, strong) NSDictionary *customData;
@property (readonly, nonatomic, strong) NSDictionary *jsonData;

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key;
- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

+ (MMGObjectBinaryOperation *)binaryOperation;
- (PMKPromise *)binaryKeys;
- (PMKPromise *)urlForKey:(NSString *)key;
- (PMKPromise *)imageForKey:(NSString *)key;

@end

@interface MMGRelationship : NSObject<MMGJSONSerializable>

@property (readonly, nonatomic, strong) NSDictionary *customData;

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key;
- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end
