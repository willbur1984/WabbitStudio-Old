//
//  WCBuildDefine.h
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"

@interface WCBuildDefine : RSObject <RSPlistArchiving,NSCopying,NSMutableCopying> {
	NSString *_name;
	NSString *_value;
}
@property (readwrite,copy,nonatomic) NSString *name;
@property (readwrite,copy,nonatomic) NSString *value;

+ (id)buildDefine;
+ (id)buildDefineWithName:(NSString *)name;
- (id)initWithName:(NSString *)name;
+ (id)buildDefineWithName:(NSString *)name value:(NSString *)value;
- (id)initWithName:(NSString *)name value:(NSString *)value;

@end
