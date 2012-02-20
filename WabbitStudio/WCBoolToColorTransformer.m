//
//  WCBoolToColorTransformer.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBoolToColorTransformer.h"

@implementation WCBoolToColorTransformer
+ (Class)transformedValueClass {
	return [NSColor class];
}
+ (BOOL)allowsReverseTransformation {
	return NO;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSNumber class]])
		return ([value boolValue])?[NSColor alternateSelectedControlTextColor]:[NSColor controlTextColor];
	return nil;
}
@end
