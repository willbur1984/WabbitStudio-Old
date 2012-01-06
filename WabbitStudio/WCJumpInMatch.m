//
//  WCJumpInMatch.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpInMatch.h"

@interface WCJumpInMatch ()
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSArray *ranges;
@property (readonly,nonatomic) NSNumber *weightNumber;
@end

@implementation WCJumpInMatch
- (void)dealloc {
	_item = nil;
	[_ranges release];
	[_name release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"item: %@ weight: %f",[self item],[self weight]];
}

- (id)forwardingTargetForSelector:(SEL)selector {
	return [self item];
}
- (id)valueForUndefinedKey:(NSString *)key {
	return [(id)[self item] valueForKey:key];
}

+ (WCJumpInMatch *)jumpInMatchWithItem:(id <WCJumpInItem>)item range:(NSRange)range weight:(CGFloat)weight; {
	return [[[[self class] alloc] initWithItem:item range:range weight:weight] autorelease];
}
- (id)initWithItem:(id <WCJumpInItem>)item range:(NSRange)range weight:(CGFloat)weight; {
	if (!(self = [super init]))
		return nil;
	
	_item = item;
	_range = range;
	_weight = weight;
	
	return self;
}
+ (WCJumpInMatch *)jumpInMatchWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight; {
	return [[[[self class] alloc] initWithItem:item ranges:ranges weight:weight] autorelease];
}
- (id)initWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight; {
	if (!(self = [super init]))
		return nil;
	
	_item = item;
	_ranges = [ranges copy];
	_weight = weight;
	
	return self;
}

@synthesize item=_item;
@dynamic name;
- (NSAttributedString *)name {
	if (!_name) {
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:[[self item] jumpInName] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],NSFontAttributeName, nil]] autorelease];
		
		if ([[self ranges] count]) {
			for (NSValue *rangeValue in [self ranges]) {
				//[temp applyFontTraits:NSBoldFontMask range:[rangeValue rangeValue]];
				[temp addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[NSColor yellowColor] colorWithAlphaComponent:0.5],NSBackgroundColorAttributeName,[[NSColor orangeColor] colorWithAlphaComponent:0.5],NSUnderlineColorAttributeName,[NSNumber numberWithInteger:NSUnderlinePatternSolid|NSUnderlineStyleDouble],NSUnderlineStyleAttributeName, nil] range:[rangeValue rangeValue]];
			}
		}
		else {
			//[temp applyFontTraits:NSBoldFontMask range:[self range]];
			[temp addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[NSColor yellowColor] colorWithAlphaComponent:0.5],NSBackgroundColorAttributeName,[[NSColor orangeColor] colorWithAlphaComponent:0.5],NSUnderlineColorAttributeName,[NSNumber numberWithInteger:NSUnderlinePatternSolid|NSUnderlineStyleDouble],NSUnderlineStyleAttributeName, nil] range:[self range]];
		}
		
		_name = [temp copy];
	}
	return _name;
}
@synthesize range=_range;
@synthesize ranges=_ranges;
@synthesize weight=_weight;
@dynamic weightNumber;
- (NSNumber *)weightNumber {
	return [NSNumber numberWithFloat:[self weight]];
}

@end
