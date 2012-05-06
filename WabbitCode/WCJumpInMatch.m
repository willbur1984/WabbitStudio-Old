//
//  WCJumpInMatch.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCJumpInMatch.h"
#import "WCDefines.h"

@interface WCJumpInMatch ()
@property (readonly,nonatomic) NSArray *ranges;
@property (readonly,nonatomic) NSArray *weights;
@end

@implementation WCJumpInMatch
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_item release];
	[_weights release];
	[_ranges release];
	[_name release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"item: %@ weight: %@",[self item],[self weights]];
}
#pragma mark *** Public Methods ***
+ (WCJumpInMatch *)jumpInMatchWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights; {
	return [[[[self class] alloc] initWithItem:item ranges:ranges weights:weights] autorelease];
}
- (id)initWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights; {
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
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:[[self item] jumpInName] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],NSFontAttributeName, nil]] autorelease];
		
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
