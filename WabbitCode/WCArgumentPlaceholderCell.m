//
//  WCArgumentPlaceholderCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCArgumentPlaceholderCell.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"
#import "RSDefines.h"
#import "AIColorAdditions.h"

NSString *const WCPasteboardTypeArgumentPlaceholderCell = @"org.revsoft.wabbitstudio.argumentplaceholder";

static NSString *const WCArgumentPlaceholderCellStringValueKey = @"stringValue";
static NSString *const WCArgumentPlaceholderCellArgumentChoicesKey = @"argumentChoices";
static NSString *const WCArgumentPlaceholderCellArgumentChoicesTypeKey = @"argumentChoicesType";

static NSTextStorage *_textStorage;
static NSLayoutManager *_layoutManager;
static NSTextContainer *_textContainer;

@interface WCArgumentPlaceholderCell ()
@property (readonly,nonatomic) WCSourceTokenType argumentChoicesType;
@end

@implementation WCArgumentPlaceholderCell
#pragma mark *** Subclass Overrides ***
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

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_argumentChoices release];
	[super dealloc];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
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
	NSTextView *textView = [layoutManager firstTextView];
	BOOL isSelected = NSLocationInRange(charIndex, [textView selectedRange]);
	BOOL backgroundColorIsLight = (![[textView backgroundColor] colorIsDark]);
	
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
	NSMutableString *string = [NSMutableString stringWithString:[self stringValue]];
	
	if ([[self argumentChoices] count])
		[string appendFormat:@" %C",0x25BC];
	
	NSColor *textColor = [NSColor blackColor];
	if (isSelected && [[controlView window] isKeyWindow]) {
		if (backgroundColorIsLight)
			textColor = [NSColor whiteColor];
	}
	else if (!backgroundColorIsLight)
		textColor = [NSColor whiteColor];
	
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName,textColor,NSForegroundColorAttributeName, nil]] autorelease];
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:attributedString];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	[_layoutManager drawGlyphsForGlyphRange:[_layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [_textStorage length]) actualCharacterRange:NULL] atPoint:cellFrame.origin];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {

	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	NSMutableString *string = [NSMutableString stringWithString:[self stringValue]];
	
	if ([[self argumentChoices] count])
		[string appendFormat:@" %C",0x25BC];
	
	[_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length]) withAttributedString:[[[NSAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil]] autorelease]];
	[_layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textStorage length])];
	
	NSRect cellFrame = [_layoutManager usedRectForTextContainer:_textContainer];
	
	cellFrame.origin = NSZeroPoint;
	cellFrame.origin.y -= [[_layoutManager typesetter] baselineOffsetInLayoutManager:_layoutManager glyphIndex:[_layoutManager glyphIndexForCharacterAtIndex:0]];
	
	return cellFrame;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	return [NSDictionary dictionaryWithObjectsAndKeys:[self stringValue],WCArgumentPlaceholderCellStringValueKey,[self argumentChoices],WCArgumentPlaceholderCellArgumentChoicesKey,[NSNumber numberWithUnsignedInt:[self argumentChoicesType]],WCArgumentPlaceholderCellArgumentChoicesTypeKey, nil];
}
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	return [self initTextCell:[plistRepresentation objectForKey:WCArgumentPlaceholderCellStringValueKey] argumentChoices:[plistRepresentation objectForKey:WCArgumentPlaceholderCellArgumentChoicesKey] argumentChoicesType:[[plistRepresentation objectForKey:WCArgumentPlaceholderCellArgumentChoicesTypeKey] unsignedIntValue]];
}

#pragma mark NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard; {
	return [NSArray arrayWithObjects:WCPasteboardTypeArgumentPlaceholderCell,NSPasteboardTypeString, nil];
}
- (id)pasteboardPropertyListForType:(NSString *)type; {
	if ([type isEqualToString:WCPasteboardTypeArgumentPlaceholderCell])
		return [self plistRepresentation];
	return [self stringValue];
}
 
#pragma mark NSPasteboardItemDataProvider
- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSString *)type; {
	if ([type isEqualToString:WCPasteboardTypeArgumentPlaceholderCell])
		[item setPropertyList:[self pasteboardPropertyListForType:type] forType:type];
	else
		[item setString:[self stringValue] forType:NSPasteboardTypeString];
}

#pragma mark *** Public Methods ***
- (id)initTextCell:(NSString *)aString argumentChoices:(NSArray *)argumentChoices argumentChoicesType:(WCSourceTokenType)argumentChoicesType; {
	if (!(self = [super initTextCell:aString]))
		return nil;
	
	_argumentChoices = [[argumentChoices sortedArrayUsingSelector:@selector(localizedStandardCompare:)] copy];
	_argumentChoicesType = argumentChoicesType;
	
	return self;
}
#pragma mark Properties
@synthesize argumentChoices=_argumentChoices;
@synthesize argumentChoicesType=_argumentChoicesType;
@dynamic icon;
- (NSImage *)icon {
	return [WCSourceToken sourceTokenIconForSourceTokenType:[self argumentChoicesType]];
}

@end
