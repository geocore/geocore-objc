//
//  MMGObject.h
//  
//
//  Created by Purbo Mohamad on 5/16/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGObjectOperation : NSObject

@property (nonatomic, strong) NSString *id;

- (instancetype)withId:(NSString *)id;

- (NSString *)buildPath:(NSString *)servicePath;
- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath;
- (NSDictionary *)buildQueryParameters;

@end

@interface MMGRelationshipOperation : NSObject

@property (nonatomic, strong) NSString *id1;
@property (nonatomic, strong) NSString *id2;
@property (nonatomic, strong) NSDictionary *customData;

- (instancetype)withObject1Id:(NSString *)id;
- (instancetype)withObject2Id:(NSString *)id;
- (instancetype)withCustomData:(NSDictionary *)dictionary;

- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath;
- (PMKPromise *)getRelationshipOfType:(Class)clazz withServicePath:(NSString *)servicePath idForSubPath:(NSString *)subPath;
- (PMKPromise *)postRelationshipOfType:(Class)clazz withServicePath:(NSString *)servicePath idForSubPath:(NSString *)subPath;

@end

@interface MMGObjectQuery : MMGObjectOperation

+ (instancetype)query;

- (instancetype)withName:(NSString *)name;
- (instancetype)updatedAfter:(NSDate *)date;
- (instancetype)havingCustomDataValue:(NSString *)value forKey:(NSString *)key;
- (instancetype)page:(NSUInteger)page;
- (instancetype)numberPerPage:(NSUInteger)numberPerPage;
- (instancetype)unlimited;

- (PMKPromise *)getObjectOfType:(Class)clazz withServicePath:(NSString *)servicePath;
- (PMKPromise *)get;

@end

@interface MMGObjectBinaryOperation : MMGObjectOperation

+ (instancetype)operation;

- (instancetype)withKey:(NSString *)key;

- (PMKPromise *)allKeys;
- (PMKPromise *)url;
- (PMKPromise *)binary;
- (PMKPromise *)image;

- (instancetype)withData:(NSData *)data;
- (instancetype)withMimeType:(NSString *)mimeType;
- (PMKPromise *)upload;

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

- (id)initWithId:(NSString *)id;

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key;
- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

+ (MMGObjectBinaryOperation *)binaryOperation;
- (PMKPromise *)binaryKeys;
- (PMKPromise *)urlForKey:(NSString *)key;
- (PMKPromise *)imageForKey:(NSString *)key;
- (PMKPromise *)upload:(NSData *)data withMimeType:(NSString *)mimeType forKey:(NSString *)key;

@end

@interface MMGRelationship : NSObject<MMGJSONSerializable>

@property (readonly, nonatomic, strong) NSDate *updateTime;
@property (readonly, nonatomic, strong) NSDictionary *customData;

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key;
- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end
