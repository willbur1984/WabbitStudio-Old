//
//  RSNavigatorControl.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSNavigatorControl.h"
#import "RSNavigatorControlCell.h"
#import "NSImage+RSExtensions.h"
#import "RSDefines.h"

@interface RSNavigatorControl ()
- (void)_commonInit;
- (void)_setupToolTips;
@end

@implementation RSNavigatorControl
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_delegate = nil;
	_dataSource = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	[_fillGradient release];
	[_alternateFillGradient release];
	[_bottomFillColor release];
	[_alternateBottomFillColor release];
	[_cells release];
	[_selectedItemIdentifier release];
	[_itemIdentifiers release];
	[_selectedFillGradient release];
	[super dealloc];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self reloadData];
}

+ (Class)cellClass {
	return [RSNavigatorControlCell class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
	NSUInteger itemIndex, numberOfItems = [_itemIdentifiers count];
	CGFloat itemWidth = [[self dataSource] itemWidthForNavigatorControl:self], totalItemWidth = numberOfItems*itemWidth;
	CGFloat startX = NSMinX([self bounds])+floor(NSWidth([self bounds])/2.0)-floor(totalItemWidth/2.0);
	NSRectArray rectsForItems = calloc(sizeof(NSRect), numberOfItems);
	NSPoint fLocation = [self convertPointFromBase:[theEvent locationInWindow]];
	
	for (itemIndex=0; itemIndex<numberOfItems; itemIndex++) {
		rectsForItems[itemIndex] = NSMakeRect(startX+(itemIndex*itemWidth), NSMinY([self bounds]), itemWidth, NSHeight([self bounds]));
		
		if (NSPointInRect(fLocation, rectsForItems[itemIndex]))
			[[_cells objectAtIndex:itemIndex] highlight:YES withFrame:rectsForItems[itemIndex] inView:self];
	}
	
	NSUInteger lastHighlightedCellIndex = NSNotFound;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSEvent *event = nil;
	while([event type] != NSLeftMouseUp) {
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		event = [[self window] nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask];
		fLocation = [self convertPointFromBase:[event locationInWindow]];
		
		for (itemIndex=0; itemIndex<numberOfItems; itemIndex++) {
			if (NSPointInRect(fLocation, rectsForItems[itemIndex])) {
				[[_cells objectAtIndex:itemIndex] highlight:YES withFrame:rectsForItems[itemIndex] inView:self];
				lastHighlightedCellIndex = itemIndex;
			}
			else
				[[_cells objectAtIndex:itemIndex] highlight:NO withFrame:rectsForItems[itemIndex] inView:self];
				
		}
	}
	
	if (lastHighlightedCellIndex != NSNotFound) {
		[[_cells objectAtIndex:lastHighlightedCellIndex] highlight:NO withFrame:rectsForItems[lastHighlightedCellIndex] inView:self];
		[self setSelectedItemIdentifier:[_itemIdentifiers objectAtIndex:lastHighlightedCellIndex]];
	}
	
	[pool release];
	free(rectsForItems);
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidBecomeKeyObservingToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_windowDidResignKeyObservingToken];
	
	if (newWindow) {
		_windowDidBecomeKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
		_windowDidResignKeyObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:newWindow queue:nil usingBlock:^(NSNotification *note) {
			[self setNeedsDisplay:YES];
		}];
	}
}

- (void)resetCursorRects {
	[super resetCursorRects];
	
	[self _setupToolTips];
}

- (void)drawRect:(NSRect)dirtyRect {
	if ([[self window] isKeyWindow])
		[_fillGradient drawInRect:[self bounds] angle:90.0];
	else
		[_alternateFillGradient drawInRect:[self bounds] angle:90.0];
	
	NSUInteger itemIndex, numberOfItems = [_itemIdentifiers count];
	CGFloat itemWidth = [[self dataSource] itemWidthForNavigatorControl:self], totalItemWidth = numberOfItems*itemWidth;
	CGFloat startX = NSMinX([self bounds])+floor(NSWidth([self bounds])/2.0)-floor(totalItemWidth/2.0);
	
	for (itemIndex=0; itemIndex<numberOfItems; itemIndex++) {
		NSRect itemRect = NSMakeRect(startX+(itemIndex*itemWidth), NSMinY([self bounds]), itemWidth, NSHeight([self bounds]));
		NSString *itemIdentifier = [_itemIdentifiers objectAtIndex:itemIndex];
		
		if ([itemIdentifier isEqualToString:[self selectedItemIdentifier]]) {
			[_selectedFillGradient drawInRect:itemRect angle:90.0];
			if ([[self window] isKeyWindow])
				[_bottomFillColor setFill];
			else
				[_alternateBottomFillColor setFill];
			NSRectFill(NSMakeRect(NSMinX(itemRect), NSMinY(itemRect), 1.0, NSHeight(itemRect)));
			NSRectFill(NSMakeRect(NSMaxX(itemRect)-1, NSMinY(itemRect), 1.0, NSHeight(itemRect)));
		}
		
		NSSize imageSize = NSSmallSize;
		if ([[self dataSource] respondsToSelector:@selector(navigatorControl:imageSizeForItemIdentifier:atIndex:)])
			imageSize = [[self dataSource] navigatorControl:self imageSizeForItemIdentifier:[_itemIdentifiers objectAtIndex:itemIndex] atIndex:itemIndex];
		NSImage *image = [[self dataSource] navigatorControl:self imageForItemIdentifier:[_itemIdentifiers objectAtIndex:itemIndex] atIndex:itemIndex];
		
		[image setSize:imageSize];
		
		[[_cells objectAtIndex:itemIndex] setImage:image];
		[[_cells objectAtIndex:itemIndex] drawWithFrame:itemRect inView:self];
	}
	
	if ([[self window] isKeyWindow])
		[_bottomFillColor setFill];
	else
		[_alternateBottomFillColor setFill];
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
}

#pragma mark NSToolTipOwner
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data {
	if ([[self dataSource] respondsToSelector:@selector(navigatorControl:toopTipForItemIdentifier:atIndex:)])
		return [[self dataSource] navigatorControl:self toopTipForItemIdentifier:(NSString *)data atIndex:[_itemIdentifiers indexOfObjectIdenticalTo:(NSString *)data]];
	return nil;
}
#pragma mark *** Public Methods ***
- (void)reloadData; {
	[_itemIdentifiers release];
	_itemIdentifiers = [[[self dataSource] itemIdentifiersForNavigatorControl:self] copy];
	
	[_cells removeAllObjects];
	for (NSUInteger itemIndex = 0; itemIndex<[_itemIdentifiers count]; itemIndex++)
		[_cells addObject:[[[self cell] copy] autorelease]];
	
	[self _setupToolTips];
	
	[self setNeedsDisplay:YES];
}
#pragma mark Properties
@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize contentView=_contentView;

@dynamic selectedItemIdentifier;
- (NSString *)selectedItemIdentifier {
	return _selectedItemIdentifier;
}
- (void)setSelectedItemIdentifier:(NSString *)selectedItemIdentifier {
	if (_selectedItemIdentifier == selectedItemIdentifier)
		return;
	
	[_selectedItemIdentifier release];
	_selectedItemIdentifier = [selectedItemIdentifier copy];
	
	NSView *subview = [[self delegate] navigatorControl:self contentViewForItemIdentifier:selectedItemIdentifier atIndex:[_itemIdentifiers indexOfObjectIdenticalTo:selectedItemIdentifier]];
	
	if (subview) {
		[subview setFrameSize:[[self contentView] frame].size];
		
		if ([[[self contentView] subviews] count])
			[[self contentView] replaceSubview:[[[self contentView] subviews] lastObject] with:subview];
		else
			[[self contentView] addSubview:subview];
		
		if ([[self delegate] respondsToSelector:@selector(navigatorControlSelectedItemIdentifierDidChange:)])
			[[self delegate] navigatorControlSelectedItemIdentifierDidChange:self];
	}
	
	[self setNeedsDisplay:YES];
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	_fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:174.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:211.0/255.0 alpha:1.0]];
	_alternateFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:209.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:244.0/255.0 alpha:1.0]];
	_bottomFillColor = [[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0] retain];
	_alternateBottomFillColor = [[NSColor colorWithCalibratedWhite:109.0/255.0 alpha:1.0] retain];
	_cells = [[NSMutableArray alloc] initWithCapacity:0];
	//_selectedFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:246.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:246.0/255.0 alpha:0.5]];
	_selectedFillGradient = [_alternateFillGradient retain];
	//_selectedFillGradient = [[NSGradient alloc] initWithColorsAndLocations:[[NSColor darkGrayColor] colorWithAlphaComponent:0.5],0.0,[NSColor clearColor],0.25,[NSColor clearColor],0.75,[[NSColor darkGrayColor] colorWithAlphaComponent:0.5],1.0, nil];
}

- (void)_setupToolTips; {
	[self removeAllToolTips];
	
	NSUInteger itemIndex, numberOfItems = [_itemIdentifiers count];
	CGFloat itemWidth = [[self dataSource] itemWidthForNavigatorControl:self], totalItemWidth = itemWidth*numberOfItems;
	CGFloat startX = NSMinX([self bounds])+floor(NSWidth([self bounds])/2.0)-floor(totalItemWidth/2.0);
	
	for (itemIndex=0; itemIndex<numberOfItems; itemIndex++) {
		NSRect itemRect = NSMakeRect(startX+(itemIndex*itemWidth), NSMinY([self bounds]), itemWidth, NSHeight([self bounds]));
		
		[self addToolTipRect:itemRect owner:self userData:[_itemIdentifiers objectAtIndex:itemIndex]];
	}
}
@end
