//
//  RSObject.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"

NSString *const RSObjectClassNameKey = @"className";

@implementation RSObject
- (NSDictionary *)plistRepresentation {
	return [NSDictionary dictionaryWithObjectsAndKeys:[self className],RSObjectClassNameKey, nil];
}
@end
