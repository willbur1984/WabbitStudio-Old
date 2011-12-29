//
//  RSDisassemblyTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 8/18/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSNoHighlightColorTextFieldCell.h"

@implementation RSNoHighlightColorTextFieldCell
#pragma mark *** Subclass Overrides ***
- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	return nil;
}

@end
