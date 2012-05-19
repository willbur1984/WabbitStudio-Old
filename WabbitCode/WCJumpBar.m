//
//  WCJumpBar.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCJumpBar.h"
#import "WCJumpBarCell.h"
#import "WCJumpBarComponentCell.h"
#import "RSToolTipManager.h"

@interface WCJumpBar ()
- (void)_commonInit;
@end

@implementation WCJumpBar
#pragma mark *** Subclass Overrides ***
+ (Class)cellClass {
	return [WCJumpBarCell class];
}

- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	
	[[RSToolTipManager sharedManager] removeView:self];
	
	if ([self window])
		[[RSToolTipManager sharedManager] addView:self];
}

- (NSArray *)toolTipManager:(RSToolTipManager *)toolTipManager toolTipProvidersForToolTipAtPoint:(NSPoint)toolTipPoint {
	WCJumpBarComponentCell *cell = (WCJumpBarComponentCell *)[[self cell] pathComponentCellAtPoint:toolTipPoint withFrame:[self bounds] inView:self];
	
	if (cell && [cell attributedToolTip])
		return [NSArray arrayWithObjects:cell, nil];
	return nil;
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	[self setCell:[[[[[self class] cellClass] alloc] initTextCell:@"/"] autorelease]];
	[self setRefusesFirstResponder:YES];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setPathStyle:NSPathStyleStandard];
}
@end
