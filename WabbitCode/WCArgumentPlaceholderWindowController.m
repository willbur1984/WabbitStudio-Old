//
//  WCArgumentPlaceholderWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCArgumentPlaceholderWindowController.h"
#import "WCArgumentPlaceholderCell.h"
#import "RSDefines.h"

@interface WCArgumentPlaceholderWindowController ()
@property (readonly,nonatomic) NSTextView *textView;

- (void)_closeArgumentPlaceholderWindowAndInsertChoice:(BOOL)insertChoice;
@end

@implementation WCArgumentPlaceholderWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:_applicationDidResignActiveObservingToken];
	[NSEvent removeMonitor:_eventMonitor];
	[_argumentPlaceholderCell release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCArgumentPlaceholderWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self tableView] setTarget:self];
	[[self tableView] setDoubleAction:@selector(_tableViewDoubleClick:)];
}

- (IBAction)showWindow:(id)sender; {
	[self performSelector:@selector(retain)];
	
	[[self window] setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
	
	_eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask|NSKeyDownMask|NSScrollWheelMask  handler:^NSEvent* (NSEvent *event) {
		switch ([event type]) {
			case NSLeftMouseDown:
			case NSRightMouseDown:
			case NSScrollWheel:
				if ([event window] != [self window])
					[self _closeArgumentPlaceholderWindowAndInsertChoice:NO];
				break;
			case NSKeyDown:
				switch ([event keyCode]) {
					case KEY_CODE_ESCAPE:
						[self _closeArgumentPlaceholderWindowAndInsertChoice:NO];
						return nil;
					case KEY_CODE_LEFT_ARROW:
					case KEY_CODE_RIGHT_ARROW:
					case KEY_CODE_SPACE:
						[self _closeArgumentPlaceholderWindowAndInsertChoice:NO];
						break;
					case KEY_CODE_RETURN:
					case KEY_CODE_ENTER:
					case KEY_CODE_TAB:
						[self _closeArgumentPlaceholderWindowAndInsertChoice:YES];
						return nil;
					case KEY_CODE_UP_ARROW:
					case KEY_CODE_DOWN_ARROW:
						[[self tableView] keyDown:event];
						return nil;
					case KEY_CODE_DELETE:
					case KEY_CODE_DELETE_FORWARD:
						break;
					default:
						[[self tableView] keyDown:event];
						return nil;
				}
				break;
			default:
				break;
		}
		return event;
	}];
	
	_applicationDidResignActiveObservingToken = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidResignActiveNotification object:[NSApplication sharedApplication] queue:nil usingBlock:^(NSNotification *note) {
		[self _closeArgumentPlaceholderWindowAndInsertChoice:NO];
	}];
	
	static NSTextFieldCell *stringSizeCell;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		stringSizeCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[stringSizeCell setAlignment:NSLeftTextAlignment];
		//[stringSizeCell setBackgroundStyle:NSBackgroundStyleLowered];
		[stringSizeCell setControlSize:NSSmallControlSize];
		//[stringSizeCell setFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	});
	
	CGFloat requiredWidth = 0.0;
	CGFloat scrollerWidth = ([NSScroller scrollerWidthForControlSize:NSSmallControlSize scrollerStyle:NSScrollerStyleOverlay]*2);
	
	for (NSString *choice in [[self argumentPlaceholderCell] argumentChoices]) {
		[stringSizeCell setStringValue:choice];
		NSSize stringSize = [stringSizeCell cellSizeForBounds:NSMakeRect(0.0, 0.0, CGFLOAT_MAX, CGFLOAT_MAX)];
		if (stringSize.width+scrollerWidth > requiredWidth)
			requiredWidth = stringSize.width+scrollerWidth;
	}
	
	CGFloat maxWidth = NSWidth([[self textView] bounds]);
	static const CGFloat maxHeight = 100.0;
	CGFloat requiredHeight = [[[self argumentPlaceholderCell] argumentChoices] count] * ([[self tableView] rowHeight]+[[self tableView] intercellSpacing].height);
	NSSize newSize = [NSScrollView frameSizeForContentSize:NSMakeSize((requiredWidth < maxWidth)?requiredWidth:maxWidth, (requiredHeight < maxHeight)?requiredHeight:maxHeight) hasHorizontalScroller:[[[self tableView] enclosingScrollView] hasHorizontalScroller] hasVerticalScroller:[[[self tableView] enclosingScrollView] hasVerticalScroller] borderType:[[[self tableView] enclosingScrollView] borderType]];
	
	NSRect newFrame = [[self window] frameRectForContentRect:NSMakeRect(NSMinX([[self window] frame]), NSMinY([[self window] frame]), newSize.width, newSize.height)];
	
	if (NSHeight([[self window] frame]) < NSHeight(newFrame))
		newFrame.origin.y -= (NSHeight(newFrame) - NSHeight([[self window] frame]));
	else if (NSHeight([[self window] frame]) > NSHeight(newFrame))
		newFrame.origin.y += (NSHeight([[self window] frame]) - NSHeight(newFrame));
	
	[[self window] setFrame:newFrame display:YES];
	
	NSUInteger glyphIndex = [[[self textView] layoutManager] glyphIndexForCharacterAtIndex:_characterIndex];
	NSRect lineRect = [[[self textView] layoutManager] lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
	NSPoint selectedPoint = [[[self textView] layoutManager] locationForGlyphAtIndex:glyphIndex];
	
	lineRect.origin.y += lineRect.size.height;
	lineRect.origin.x += selectedPoint.x;
	
	[[self window] setFrameTopLeftPoint:[[[self textView] window] convertBaseToScreen:[[self textView] convertPointToBase:lineRect.origin]]];
	
	[[[self textView] window] addChildWindow:[self window] ordered:NSWindowAbove];
	[[self window] orderFront:nil];
}

+ (WCArgumentPlaceholderWindowController *)argumentPlaceholderWindowControllerWithArgumentPlaceholderCell:(WCArgumentPlaceholderCell *)argumentPlaceholderCell characterIndex:(NSUInteger)characterIndex textView:(NSTextView *)textView; {
	return [[[[self class] alloc] initWithArgumentPlaceholderCell:argumentPlaceholderCell characterIndex:characterIndex textView:textView] autorelease];
}
- (id)initWithArgumentPlaceholderCell:(WCArgumentPlaceholderCell *)argumentPlaceholderCell characterIndex:(NSUInteger)characterIndex textView:(NSTextView *)textView; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_argumentPlaceholderCell = [argumentPlaceholderCell retain];
	_characterIndex = characterIndex;
	_textView = textView;
	
	return self;
}

@synthesize tableView=_tableView;
@synthesize textView=_textView;
@synthesize arrayController=_arrayController;

@synthesize argumentPlaceholderCell=_argumentPlaceholderCell;

- (void)_closeArgumentPlaceholderWindowAndInsertChoice:(BOOL)insertChoice; {
	[self autorelease];
	
	[[[self textView] window] removeChildWindow:[self window]];
	[[self window] orderOut:nil];
	
	if (insertChoice) {
		NSString *string = [[[self arrayController] selectedObjects] lastObject];
		
		if ([[self textView] shouldChangeTextInRange:NSMakeRange(_characterIndex, 1) replacementString:string]) {
			[[self textView] replaceCharactersInRange:NSMakeRange(_characterIndex, 1) withString:string];
			[[self textView] didChangeText];
			
			[[self textView] setSelectedRange:NSMakeRange(_characterIndex, [string length])];
		}
	}
	
	[NSEvent removeMonitor:_eventMonitor];
	_eventMonitor = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:_applicationDidResignActiveObservingToken];
}

- (IBAction)_tableViewDoubleClick:(id)sender; {
	if ([[[self arrayController] selectedObjects] count])
		[self _closeArgumentPlaceholderWindowAndInsertChoice:YES];
}

@end
