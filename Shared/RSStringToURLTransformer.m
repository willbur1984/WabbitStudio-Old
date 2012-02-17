//
//  RSStringToURLTransformer.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSStringToURLTransformer.h"

@implementation RSStringToURLTransformer
+ (Class)transformedValueClass {
	return [NSURL class];
}
+ (BOOL)allowsReverseTransformation {
	return YES;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]])
		return [NSURL fileURLWithPath:value isDirectory:YES];
	return nil;
}
- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSURL class]])
		return [value path];
	return nil;
}
@end
