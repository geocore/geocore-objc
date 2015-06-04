//
//  MMGGenericResult.h
//  
//
//  Created by Purbo Mohamad on 5/18/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGGenericResult : NSObject<MMGJSONSerializable>

@property (readonly, nonatomic, assign) NSDictionary *json;

@end
