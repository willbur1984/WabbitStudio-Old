//
//  WCEditBuildTargetInputFileIconTransformer.m
//  WabbitStudio
//
//  Created by William Towe on 2/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetInputFileIconTransformer.h"
#import "RSDefines.h"

@implementation WCEditBuildTargetInputFileIconTransformer
+ (Class)transformedValueClass {
	return [NSImage class];
}
+ (BOOL)allowsReverseTransformation {
	return NO;
}
- (id)transformedValue:(id)value {
	if (value) {
		[value setSize:NSSmallSize];
		return value;
	}
	return [NSImage imageNamed:@"FileNotFound"];
}
@end
