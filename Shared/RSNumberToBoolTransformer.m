//
//  RSNumberToBoolValueTransformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSNumberToBoolTransformer.h"

@implementation RSNumberToBoolTransformer
+ (Class)transformedValueClass {
	return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation {
	return NO;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSNumber class]]) {
		if (![value integerValue])
			return [NSNumber numberWithBool:NO];
		return [NSNumber numberWithBool:YES];
	}
	return [NSNumber numberWithBool:NO];
}
@end
