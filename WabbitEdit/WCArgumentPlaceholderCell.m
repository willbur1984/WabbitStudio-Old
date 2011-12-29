//
//  WCArgumentPlaceholderCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCArgumentPlaceholderCell.h"
#import "NSBezierPath+StrokeExtensions.h"

static NSTextStorage *_textStorage;
static NSLayoutManager *_layoutManager;
static NSTextContainer *_textContainer;

@implementation WCArgumentPlaceholderCell
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_textStorage = [[NSTextStorage alloc] init];
		_layoutManager = [[NSLayoutManager alloc] init];
		_textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
		
		[_textStorage addLayoutManager:_layoutManager];
		[_layoutManager addTextContainer:_textContainer];
	});
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex {	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 0.0, 0.0) xRadius:5.0 yRadius:5.0];
	BOOL isSelected = NO;
	if ([controlView isKindOfClass:[NSTextView class]])
		isSelected = NSLocationInRange(charIndex, [(NSTextView *)controlView selectedRange]);
	
	if ([[controlView window] isKeyWindow]) {
		if (isSelected) {
			[[NSColor colorWithCalibratedRed:131.0/255.0 green:166.0/255.0 blue:239.0/255.0 alpha:1.0] setFill];
			[path fill];
		}
		else {
			[[NSColor colorWithCalibratedRed:0.871 green:0.906 blue:0.973 alpha:1.0] setFill];
			[path fill];
			[[NSColor colorWithCalibratedRed:0.643 green:0.741 blue:0.925 alpha:1.0] setStroke];
			[path strokeInside];
		}
	}
	else {
		[[NSColor colorWithCalibratedRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0] setFill];
		[path fill];
		[[NSColor colorWithCalibratedRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] setStroke];
		[path strokeInside];
	}
	
	[NSGraphicsContext saveGraphicsState];
	
	NSRectClip(cellFrame);
	
	//WCFontsAndColorsTheme *currentTheme = [[WCFontsAndColorsViewController sharedFontsAndColorsViewController] currentTheme];
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:[[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Menlo" size:11.0],NSFontAttributeName,(isSelected && [[controlView window] isKeyWindow])?[NSColor alternateSelectedControlTextColor]:[NSColor textColor],NSForegroundColorAttributeName, nil]] autorelease]];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	[_layoutManager drawGlyphsForGlyphRange:[_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL] atPoint:cellFrame.origin];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
	
	//WCFontsAndColorsTheme *currentTheme = [[WCFontsAndColorsViewController sharedFontsAndColorsViewController] currentTheme];
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:[[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Menlo" size:11.0],NSFontAttributeName, nil]] autorelease]];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	NSRect cellFrame = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
	NSRect textFrame = [_layoutManager usedRectForTextContainer:_textContainer];
	cellFrame.size.width = NSWidth(textFrame);
	cellFrame.size.height = NSHeight(textFrame);
	cellFrame.origin.y -= [[_layoutManager typesetter] baselineOffsetInLayoutManager:_layoutManager glyphIndex:0];
	
	return cellFrame;
}
@end
