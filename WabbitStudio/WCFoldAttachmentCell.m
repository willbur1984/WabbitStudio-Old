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

static NSTextStorage *_textStorage;
static NSLayoutManager *_layoutManager;
static NSTextContainer *_textContainer;

@implementation WCFoldAttachmentCell
+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_textStorage = [[NSTextStorage alloc] init];
		_layoutManager = [[[NSLayoutManager alloc] init] autorelease];
		_textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)] autorelease];
		
		[_textStorage addLayoutManager:_layoutManager];
		[_layoutManager addTextContainer:_textContainer];
	});
}

- (id)initTextCell:(NSString *)aString {
	if (!(self = [super initTextCell:[NSString stringWithFormat:@"%C",0x2026]]))
		return nil;
	
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:5.0 yRadius:5.0];
	NSTextView *textView = [layoutManager firstTextView];
	BOOL isSelected = NSLocationInRange(charIndex, [textView selectedRange]);
	
	if (isSelected) {
		
	}
	else {
		[[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:196.0/255.0 alpha:1.0] setFill];
		[path fill];
		[[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] setStroke];
		[path strokeInside];
	}
	
	[NSGraphicsContext saveGraphicsState];
	
	NSRectClip(cellFrame);
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	NSColor *textColor = [NSColor colorWithCalibratedRed:129.0/255.0 green:116.0/255.0 blue:34.0/255.0 alpha:1.0];
	
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,textColor,NSForegroundColorAttributeName, nil]] autorelease];
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:attributedString];
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
