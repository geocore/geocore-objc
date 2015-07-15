//
//  MMGObject.m
//  
//
//  Created by Purbo Mohamad on 5/16/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import "Geocore.h"
#import "GeocorePrivate.h"

@interface MMGObjectQuery()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSString *customDataValue;
@property (nonatomic, strong) NSString *customDataKey;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger numberPerPage;
@property (nonatomic, assign) BOOL unlimitedRecords;

@end

@interface MMGObjectBinaryOperation()

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSData *data;

@end


@interface MMGObject()

@property (readwrite, nonatomic, assign) long sid;
@property (readwrite, nonatomic, strong) NSDate *createTime;
@property (readwrite, nonatomic, strong) NSDate *updateTime;
@property (readwrite, nonatomic, assign) long upvotes;
@property (readwrite, nonatomic, assign) long downvotes;
@property (readwrite, nonatomic, strong) NSMutableDictionary *internalCustomData;
@property (readwrite, nonatomic, strong) NSMutableDictionary *internalJsonData;

@end

@interface MMGRelationship()

@property (readwrite, nonatomic, strong) NSDate *updateTime;
@property (readwrite, nonatomic, strong) NSMutableDictionary *internalCustomData;

@end

@implementation MMGObject

- (id)init {
    if (self = [super init]) {
        self.internalCustomData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithId:(NSString *)id {
    if (self = [self init]) {
        self.id = id;
    }
    return self;
}

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.sid = [[jsonData optionalValueForKey:@"sid" withDefaultValue:@(MMG_UNDEFINED_SID)] longValue];
    self.id = [jsonData optionalValueForKey:@"id" withDefaultValue:nil];
    self.name = [jsonData optionalValueForKey:@"name" withDefaultValue:nil];
    self.desc = [jsonData optionalValueForKey:@"description" withDefaultValue:nil];
    self.createTime = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"createTime" withDefaultValue:nil]];
    self.updateTime = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"updateTime" withDefaultValue:nil]];
    self.upvotes = [[jsonData optionalValueForKey:@"upvotes" withDefaultValue:@(0)] longValue];
    self.downvotes = [[jsonData optionalValueForKey:@"downvotes" withDefaultValue:@(0)] longValue];
    self.internalCustomData = [NSMutableDictionary dictionaryWithDictionary:[jsonData optionalValueForKey:@"customData" withDefaultValue:[NSMutableDictionary dictionary]]];
    self.internalJsonData = [NSMutableDictionary dictionaryWithDictionary:[jsonData optionalValueForKey:@"jsonData" withDefaultValue:[NSMutableDictionary dictionary]]];
    return self;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setOptionalValue:self.sid != MMG_UNDEFINED_SID ? @(self.sid) : nil forKey:@"sid"];
    [dict setOptionalValue:self.id forKey:@"id"];
    [dict setOptionalValue:self.name forKey:@"name"];
    [dict setOptionalValue:self.desc forKey:@"description"];
    [dict setOptionalValue:[self.internalCustomData count] > 0 ? self.internalCustomData : nil forKey:@"customData"];
    // TODO: jsonData
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *)customData {
    return [NSDictionary dictionaryWithDictionary:_internalCustomData];
}

- (NSDictionary *)jsonData {
    return [NSDictionary dictionaryWithDictionary:_internalJsonData];
}

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key {
    [_internalCustomData setObject:value forKey:key];
    return self;
}

- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    [_internalCustomData addEntriesFromDictionary:keyedValues];
    return self;
}

+ (MMGObjectBinaryOperation *)binaryOperation {
    return [MMGObjectBinaryOperation operation];
}

- (PMKPromise *)binaryKeys {
    return [[[MMGObjectBinaryOperation operation] withId:self.id] allKeys];
}

- (PMKPromise *)urlForKey:(NSString *)key {
    return [[[[MMGObjectBinaryOperation operation]
                                        withId:self.id]
                                        withKey:key]
                                        url];
}

- (PMKPromise *)imageForKey:(NSString *)key {
    return [[[[MMGObjectBinaryOperation operation]
                                        withId:self.id]
                                        withKey:key]
                                        image];
}

- (PMKPromise *)upload:(NSData *)data withMimeType:(NSString *)mimeType forKey:(NSString *)key {
    return [[[[[[MMGObjectBinaryOperation operation]
                                          withId:self.id]
                                          withKey:key]
                                          withMimeType:mimeType]
                                          withData:data]
                                          upload];
}

@end

@implementation MMGRelationship

- (id)init {
    if (self = [super init]) {
        self.internalCustomData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)fromJSON:(NSDictionary *)jsonData {
    self.updateTime = [[Geocore dateFormatter] dateFromOptionalString:[jsonData optionalValueForKey:@"updateTime" withDefaultValue:nil]];
    self.internalCustomData = [jsonData optionalValueForKey:@"customData" withDefaultValue:[NSMutableDictionary dictionary]];
    return self;
}

- (NSDictionary *)toJSON {
    /*
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setOptionalValue:[self.internalCustomData count] > 0 ? self.internalCustomData : nil forKey:@"customData"];
    return [NSDictionary dictionaryWithDictionary:dict];
    */
    return self.internalCustomData;
}

- (NSDictionary *)customData {
    return [NSDictionary dictionaryWithDictionary:_internalCustomData];
}

- (instancetype)setCustomDataValue:(id)value forKey:(NSString *)key {
    [_internalCustomData setObject:value forKey:key];
    return self;
}

- (instancetype)setCustomDataValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    [_internalCustomData addEntriesFromDictionary:keyedValues];
    return self;
}

@end

@implementation MMGObjectOperation

- (instancetype)withId:(NSString *)id {
    self.id = id;
    return self;
}

- (NSString *)buildPath:(NSString *)servicePath {
    if (self.id) {
        return [NSString stringWithFormat:@"%@/%@", servicePath, self.id];
    } else {
        return servicePath;
    }
}

- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath {
    if (self.id) {
        return [NSString stringWithFormat:@"%@/%@%@", servicePath, self.id, subPath];
    } else {
        return nil;
    }
}

- (NSDictionary *)buildQueryParameters {
    return [NSDictionary dictionary];
}

@end

@implementation MMGRelationshipOperation

- (instancetype)withObject1Id:(NSString *)id {
    self.id1 = id;
    return self;
}

- (instancetype)withObject2Id:(NSString *)id {
    self.id2 = id;
    return self;
}

- (instancetype)withCustomData:(NSDictionary *)dictionary {
    self.customData = dictionary;
    return self;
}

- (NSString *)buildPath:(NSString *)servicePath withIdForSubPath:(NSString *)subPath {
    if (self.id1) {
        if (self.id2) {
            return [NSString stringWithFormat:@"%@/%@%@/%@", servicePath, self.id1, subPath, self.id2];
        } else {
            return [NSString stringWithFormat:@"%@/%@%@", servicePath, self.id1, subPath];
        }
    } else {
        return nil;
    }
}

- (PMKPromise *)getRelationshipOfType:(Class)clazz withServicePath:(NSString *)servicePath idForSubPath:(NSString *)subPath {
    // if both id1 and id2 specified, this will return a specific relationship, if only id1 specified an array of relationships will be returned.
    NSString *path = [self buildPath:servicePath withIdForSubPath:subPath];
    if (path) {
        return [[Geocore instance] GET:path resultClass:clazz];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)postRelationshipOfType:(Class)clazz withServicePath:(NSString *)servicePath idForSubPath:(NSString *)subPath {
    if (self.id1 && self.id2) {
        return [[Geocore instance] POST:[self buildPath:servicePath withIdForSubPath:subPath]
                                   body:self.customData
                            resultClass:clazz];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

@end


@implementation MMGObjectQuery

+ (instancetype)query {
    return [MMGObjectQuery new];
}

- (id)init {
    if (self = [super init]) {
        self.unlimitedRecords = NO;
    }
    return self;
}

- (instancetype)withName:(NSString *)name {
    self.name = name;
    return self;
}

- (instancetype)updatedAfter:(NSDate *)date {
    self.fromDate = date;
    return self;
}

- (instancetype)havingCustomDataValue:(NSString *)value forKey:(NSString *)key {
    self.customDataKey = key;
    self.customDataValue = value;
    return self;
}

- (instancetype)page:(NSUInteger)page {
    self.page = page;
    return self;
}

- (instancetype)numberPerPage:(NSUInteger)numberPerPage {
    self.numberPerPage = numberPerPage;
    return self;
}

- (instancetype)unlimited {
    self.unlimitedRecords = YES;
    return self;
}

- (NSDictionary *)buildQueryParameters {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super buildQueryParameters]];
    if (self.unlimitedRecords) {
        [dict setObject:@(0) forKey:@"num"];
    } else {
        if (self.page > 0) {
            [dict setObject:@(self.page) forKey:@"page"];
        }
        if (self.numberPerPage > 0) {
            [dict setObject:@(self.numberPerPage) forKey:@"num"];
        }
    }
    if (self.fromDate) {
        [dict setObject:[[Geocore dateFormatter] stringFromDate:self.fromDate] forKey:@"from_date"];
    }
    return dict;
}

- (PMKPromise *)getObjectOfType:(Class)clazz withServicePath:(NSString *)servicePath {
    NSString *path = [super buildPath:servicePath];
    if (path) {
        return [[Geocore instance] GET:path resultClass:clazz];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)get {
    return [self getObjectOfType:[MMGObject class] withServicePath:@"/objs"];
}

@end

@implementation MMGObjectBinaryOperation

+ (instancetype)operation {
    return [MMGObjectBinaryOperation new];
}

- (instancetype)withKey:(NSString *)key {
    self.key = key;
    return self;
}

- (instancetype)withData:(NSData *)data {
    self.data = data;
    return self;
}

- (instancetype)withMimeType:(NSString *)mimeType {
    self.mimeType = mimeType;
    return self;
}

- (PMKPromise *)allKeys {
    NSString *path = [super buildPath:@"/objs" withIdForSubPath:@"/bins"];
    if (path) {
        return [[Geocore instance] GET:path
                            parameters:nil
                           resultClass:nil];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

- (PMKPromise *)url {
    if (self.id && self.key) {
        return [[Geocore instance] GET:[super buildPath:@"/objs" withIdForSubPath:[NSString stringWithFormat:@"/bins/%@/url", _key]]
                            parameters:nil
                           resultClass:[MMGGenericResult class]
                            preProcess:nil
                           postProcess:^NSString *(id result) {
                               if ([result class] == [MMGGenericResult class]) {
                                   MMGGenericResult *genericResult = (MMGGenericResult *)result;
                                   NSString *url = [genericResult.json objectForKey:@"url"];
                                   MMG_DEBUG(@"[DEBUG] receiving url: %@ for object id: %@, key: %@", url, self.id, self.key)
                                   // if it's an https, make it http
                                   if ([url hasPrefix:@"https"]) {
                                       url = [NSString stringWithFormat:@"http%@", [url substringFromIndex:5]];
                                   }
                                   return url;
                               } else {
                                   MMG_DEBUG(@"[ERROR] receiving unexpected object, possibly an error: %@", result)
                                   return result;
                               }
                           }];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id and/or key not set"}]];
    }
}

- (PMKPromise *)binaryWithSerializer:(AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        [self url]
        .then(^(NSString *url) {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = responseSerializer;
            [manager GET:url
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     resolve(responseObject);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     MMG_DEBUG(@"[ERROR] Error getting data: %@", error);
                     resolve(error);
                 }
             ];
        })
        .catch(^(NSError *error) {
            resolve(error);
        });
    }];
}

- (PMKPromise *)binary {
    return [self binaryWithSerializer:[AFHTTPResponseSerializer serializer]];
}

- (PMKPromise *)image {
    return [self binaryWithSerializer:[AFImageResponseSerializer serializer]];
}

- (PMKPromise *)upload {
    if (!self.key || !self.mimeType || !self.data) {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"key, mimeType, or data not set"}]];
    }
    NSString *path = [super buildPath:@"/objs" withIdForSubPath:[NSString stringWithFormat:@"/bins/%@", _key]];
    if (path) {
        return [[Geocore instance] POST:_data
                           withMimeType:_mimeType
                                 toPath:path];
    } else {
        return [PMKPromise promiseWithValue:[NSError errorWithDomain:MMGErrorDomain code:kMMGErrorInvalidParameter userInfo:@{@"message": @"id not set"}]];
    }
}

@end

