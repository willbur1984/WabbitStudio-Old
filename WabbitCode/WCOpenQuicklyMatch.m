//
//  WCOpenQuicklyMatch.m
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCOpenQuicklyMatch.h"
#import "WCDefines.h"

@interface WCOpenQuicklyMatch ()
@property (readonly,nonatomic) NSArray *ranges;
@property (readonly,nonatomic) NSArray *weights;
@end

@implementation WCOpenQuicklyMatch
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_item release];
	[_weights release];
	[_ranges release];
	[_name release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"item: %@ weights: %@",[self item],[self weights]];
}
#pragma mark *** Public Methods ***
+ (WCOpenQuicklyMatch *)openQuicklyMatchWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights; {
	return [[[[self class] alloc] initWithItem:item ranges:ranges weights:weights] autorelease];
}
- (id)initWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights; {
	if (!(self = [super init]))
		return nil;
	
	_item = [item retain];
	_ranges = [ranges copy];
	_weights = [weights copy];
	
	return self;
}
#pragma mark Properties
@synthesize item=_item;
@dynamic name;
- (NSAttributedString *)name {
	if (!_name) {
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:[[self item] openQuicklyName] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],NSFontAttributeName, nil]] autorelease];
		
		if ([[self ranges] count]) {
			NSDictionary *attributes = WCTransparentFindTextAttributes();
			for (NSValue *rangeValue in [self ranges])
				[temp addAttributes:attributes range:[rangeValue rangeValue]];
		}
		
		_name = [temp copy];
	}
	return _name;
}
@synthesize ranges=_ranges;
@synthesize weights=_weights;
@dynamic contiguousRangeWeight;
- (CGFloat)contiguousRangeWeight {
	return [[[self weights] objectAtIndex:0] floatValue];
}
@dynamic lengthDifferenceWeight;
- (CGFloat)lengthDifferenceWeight {
	return [[[self weights] objectAtIndex:1] floatValue];
}
@dynamic matchOffsetWeight;
- (CGFloat)matchOffsetWeight {
	return [[[self weights] objectAtIndex:2] floatValue];
}

@end
