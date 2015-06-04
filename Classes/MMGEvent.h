//
//  MMGEvent.h
//  AnchorUp
//
//  Created by Purbo Mohamad on 5/20/15.
//  Copyright (c) 2015 MapMotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMGEventQuery : MMGTaggableQuery

+ (instancetype)query;
- (PMKPromise *)all;

@end


@interface MMGEvent : MMGTaggable

@property (nonatomic, strong) NSDate *timeStart;
@property (nonatomic, strong) NSDate *timeEnd;

+ (MMGEventQuery *)query;

@end
