//
//  WCSplitView.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSplitView.h"

@implementation WCSplitView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_dividerColor release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	_dividerColor = [[super dividerColor] retain];
	
	return self;
}
#pragma mark *** Public Methods ***
@dynamic dividerColor;
- (NSColor *)dividerColor {
	if ([self dividerStyle] == NSSplitViewDividerStyleThin)
		return _dividerColor;
	return [super dividerColor];
}
- (void)setDividerColor:(NSColor *)dividerColor {
	if (_dividerColor == dividerColor)
		return;
	
	[_dividerColor release];
	_dividerColor = [dividerColor retain];
	
	[self setNeedsDisplay:YES];
}
@end
