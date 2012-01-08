//
//  WCSplitView.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSplitView.h"

@implementation WCSplitView

- (void)dealloc {
	[_dividerColor release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	_dividerColor = [[super dividerColor] retain];
	
	return self;
}

@dynamic dividerColor;
- (NSColor *)dividerColor {
	return _dividerColor;
}
- (void)setDividerColor:(NSColor *)dividerColor {
	if (_dividerColor == dividerColor)
		return;
	
	[_dividerColor release];
	_dividerColor = [dividerColor retain];
	
	[self setNeedsDisplay:YES];
}
@end
