//
//  RSNegateNumberToBoolTransformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSNegateNumberToBoolTransformer.h"

@implementation RSNegateNumberToBoolTransformer
#pragma mark *** Subclass Overrides ***
+ (Class)transformedValueClass {
	return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation {
	return NO;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSNumber class]]) {
		if ([value unsignedIntegerValue])
			return [NSNumber numberWithBool:NO];
		return [NSNumber numberWithBool:YES];
	}
	return [NSNumber numberWithBool:YES];
}
@end
