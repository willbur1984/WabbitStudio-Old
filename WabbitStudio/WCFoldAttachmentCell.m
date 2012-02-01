//
//  WCFoldAttachmentCell.m
//  WabbitStudio
//
//  Created by William Towe on 1/25/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFoldAttachmentCell.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCSourceTextStorage.h"
#import "RSDefines.h"
#import "WCSourceTextView.h"

static NSTextStorage *_textStorage;
static NSLayoutManager *_layoutManager;
static NSTextContainer *_textContainer;

static const CGFloat kCellPaddingLeftRight = 2.0;

@implementation WCFoldAttachmentCell
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// [NSString stringWithFormat:@"%C",0x2026]
		_textStorage = [[NSTextStorage alloc] initWithString:[NSString stringWithFormat:@"%C",0x2026] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedRed:129.0/255.0 green:116.0/255.0 blue:34.0/255.0 alpha:1.0],NSForegroundColorAttributeName, nil]];
		_layoutManager = [[[NSLayoutManager alloc] init] autorelease];
		[_textStorage addLayoutManager:_layoutManager];
		_textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)] autorelease];
		[_layoutManager addTextContainer:_textContainer];
	});
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex {
	return NSPointInRect([controlView convertPointFromBase:[theEvent locationInWindow]], cellFrame);
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag {
	if ([controlView respondsToSelector:@selector(unfold:)]) {
		[(WCSourceTextView *)controlView setSelectedRange:NSMakeRange(charIndex, 0)];
		[(WCSourceTextView *)controlView unfold:nil];
		return YES;
	}
	return NO;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, kCellPaddingLeftRight, 1.0) xRadius:5.0 yRadius:5.0];
	
	[[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:196.0/255.0 alpha:1.0] setFill];
	[path fill];
	[[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] setStroke];
	[path stroke];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSRectClip(cellFrame);
    
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[_textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil] range:NSMakeRange(0, [_textStorage length])];
	
	cellFrame.origin.x += kCellPaddingLeftRight;
	
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	[_layoutManager drawGlyphsForGlyphRange:[_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL] atPoint:cellFrame.origin];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[_textStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil] range:NSMakeRange(0, [_textStorage length])];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	NSRect cellFrame = [_layoutManager usedRectForTextContainer:_textContainer];
	
    cellFrame.origin = NSZeroPoint;
	cellFrame.origin.y -= [[_layoutManager typesetter] baselineOffsetInLayoutManager:_layoutManager glyphIndex:[_layoutManager glyphIndexForCharacterAtIndex:0]];
	cellFrame.size.width += kCellPaddingLeftRight*2;
	
    return cellFrame;
}
@end
