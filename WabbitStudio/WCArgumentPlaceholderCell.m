//
//  WCArgumentPlaceholderCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCArgumentPlaceholderCell.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "NSColor+ContrastingLabelExtensions.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"

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
	static NSColor *lightSelectedFillColor;
	static NSColor *lightNotSelectedKeyFillColor;
	static NSColor *lightNotSelectedKeyStrokeColor;
	static NSColor *lightNonKeyFillColor;
	static NSColor *lightNonKeyStrokeColor;
	static NSColor *darkSelectedFillColor;
	static NSColor *darkNotSelectedKeyFillColor;
	static NSColor *darkNotSelectedKeyStrokeColor;
	static NSColor *darkNonKeyFillColor;
	static NSColor *darkNonKeyStrokeColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		lightSelectedFillColor = [[NSColor colorWithCalibratedRed:131.0/255.0 green:166.0/255.0 blue:239.0/255.0 alpha:1.0] retain];
		lightNotSelectedKeyFillColor = [[NSColor colorWithCalibratedRed:0.871 green:0.906 blue:0.973 alpha:1.0] retain];
		lightNotSelectedKeyStrokeColor = [[NSColor colorWithCalibratedRed:0.643 green:0.741 blue:0.925 alpha:1.0] retain];
		lightNonKeyFillColor = [[NSColor colorWithCalibratedRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0] retain];
		lightNonKeyStrokeColor = [[NSColor colorWithCalibratedRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] retain];
		
		darkSelectedFillColor = [[NSColor colorWithCalibratedRed:36.0/255.0 green:81.0/255.0 blue:154.0/255.0 alpha:1.0] retain];
		darkNotSelectedKeyFillColor = [[NSColor colorWithCalibratedRed:141.0/255.0 green:151.0/255.0 blue:164.0/255.0 alpha:1.0] retain];
		darkNotSelectedKeyStrokeColor = [[NSColor colorWithCalibratedRed:94.0/255.0 green:117.0/255.0 blue:154.0/255.0 alpha:1.0] retain];
		darkNonKeyFillColor = [[NSColor colorWithCalibratedRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0] retain];
		darkNonKeyStrokeColor = [[NSColor colorWithCalibratedRed:116.0/255.0 green:116.0/255.0 blue:116.0/255.0 alpha:1.0] retain];
	});
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:5.0 yRadius:5.0];
	BOOL isSelected = NO;
	BOOL backgroundColorIsLight = YES;
	if ([controlView isKindOfClass:[NSTextView class]]) {
		isSelected = NSLocationInRange(charIndex, [(NSTextView *)controlView selectedRange]);
		backgroundColorIsLight = [[[(NSTextView *)controlView backgroundColor] contrastingLabelColor] isEqualTo:[NSColor blackColor]];
	}
	
	if ([[controlView window] isKeyWindow]) {
		if (isSelected) {
			if (backgroundColorIsLight)
				[lightSelectedFillColor setFill];
			else
				[darkSelectedFillColor setFill];
			[path fill];
		}
		else {
			if (backgroundColorIsLight)
				[lightNotSelectedKeyFillColor setFill];
			else
				[darkNotSelectedKeyFillColor setFill];
			[path fill];
			if (backgroundColorIsLight)
				[lightNotSelectedKeyStrokeColor setStroke];
			else
				[darkNotSelectedKeyStrokeColor setStroke];
			[path strokeInside];
		}
	}
	else {
		if (backgroundColorIsLight)
			[lightNonKeyFillColor setFill];
		else
			[darkNonKeyFillColor setFill];
		[path fill];
		if (backgroundColorIsLight)
			[lightNonKeyStrokeColor setStroke];
		else
			[darkNonKeyStrokeColor setStroke];
		[path strokeInside];
	}
	
	[NSGraphicsContext saveGraphicsState];
	
	NSRectClip(cellFrame);
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSColor *textColor = [NSColor blackColor];
	if (isSelected && [[controlView window] isKeyWindow]) {
		if (backgroundColorIsLight)
			textColor = [NSColor whiteColor];
	}
	else if (!backgroundColorIsLight)
		textColor = [NSColor whiteColor];
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:[[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,textColor,NSForegroundColorAttributeName, nil]] autorelease]];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	[_layoutManager drawGlyphsForGlyphRange:[_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL] atPoint:cellFrame.origin];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:[[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil]] autorelease]];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	NSRect cellFrame = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
	NSRect textFrame = [_layoutManager usedRectForTextContainer:_textContainer];
	cellFrame.size.width = NSWidth(textFrame);
	cellFrame.size.height = NSHeight(textFrame);
	cellFrame.origin.y -= [[_layoutManager typesetter] baselineOffsetInLayoutManager:_layoutManager glyphIndex:0];
	
	return cellFrame;
}
@end
