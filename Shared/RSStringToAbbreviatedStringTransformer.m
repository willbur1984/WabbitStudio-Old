//
//  RSStringToAbbreviatedStringTransformer.m
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSStringToAbbreviatedStringTransformer.h"

@implementation RSStringToAbbreviatedStringTransformer
#pragma mark *** Subclass Overrides ***
+ (Class)transformedValueClass {
	return [NSString class];
}
+ (BOOL)allowsReverseTransformation {
	return YES;
}
- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]])
		return [value stringByAbbreviatingWithTildeInPath];
	return nil;
}
- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSString class]])
		return [value stringByExpandingTildeInPath];
	return nil;
}
@end
