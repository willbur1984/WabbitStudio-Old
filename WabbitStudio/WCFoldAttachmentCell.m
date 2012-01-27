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

static NSImage *triangleImage = nil;
static NSGradient *gradient = nil;
static NSLayoutManager *scratchLayoutManager = nil;
static NSTextStorage *scratchTextStorage = nil;
static NSLayoutManager *realLayoutManager = nil;
static NSTextContainer *realTextContainer = nil;

@implementation WCFoldAttachmentCell
+ (void)initialize {
	// 129 116 34
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSZeroSize];
		
        triangleImage = [[NSImage imageNamed:NSImageNameRightFacingTriangleTemplate] retain];
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor redColor]];
        scratchLayoutManager = [[NSLayoutManager alloc] init];
        [scratchLayoutManager addTextContainer:textContainer];
        [textContainer release];
		realTextContainer = [[NSTextContainer alloc] init];
		realLayoutManager = [[NSLayoutManager alloc] init];
		scratchTextStorage = [[NSTextStorage alloc] initWithString:[NSString stringWithFormat:@"%C",0x2026] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedRed:129.0/255.0 green:116.0/255.0 blue:34.0/255.0 alpha:1.0],NSForegroundColorAttributeName, nil]];
		[realLayoutManager addTextContainer:realTextContainer];
		[scratchTextStorage addLayoutManager:realLayoutManager];
	});
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 0.0, 0.5) xRadius:5.0 yRadius:5.0];
    NSTextContainer *textContainer = [layoutManager textContainerForGlyphAtIndex:[layoutManager glyphIndexForCharacterAtIndex:charIndex] effectiveRange:NULL];
    NSTextStorage *textStorage = [layoutManager textStorage];
    NSTextContainer *scratchContainer = [[scratchLayoutManager textContainers] objectAtIndex:0];
    NSRect textFrame;
    NSRange glyphRange;
    BOOL lineFoldingEnabled;
    
    if (layoutManager == scratchLayoutManager) return; // don't render for scratchLayoutManager
    
    //[gradient drawInBezierPath:path angle:85.0];
    
    //[[[self class] disclosureTriangleImage] drawInRect:triangleRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	[[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:196.0/255.0 alpha:1.0] setFill];
	[path fill];
	[[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] setStroke];
	[path stroke];
    
    // render text
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    
    [context saveGraphicsState];
    
    lineFoldingEnabled = [(WCSourceTextStorage *)textStorage lineFoldingEnabled];
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:NO];
    
    //cellFrame.size.width = (NSMaxX(cellFrame) - HorizontalInset) - NSMaxX(triangleRect);
    //cellFrame.origin.x = NSMaxX(triangleRect);
    
    NSRectClip(cellFrame);
    
    if ([scratchLayoutManager textStorage] != textStorage) {
        [textStorage addLayoutManager:scratchLayoutManager];
    }
    
    if (!NSEqualSizes([textContainer containerSize], [scratchContainer containerSize])) [scratchContainer setContainerSize:[textContainer containerSize]];
    
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[scratchTextStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil] range:NSMakeRange(0, [scratchTextStorage length])];
	//[scratchTextStorage replaceCharactersInRange:NSMakeRange(0, [scratchTextStorage length]) withString:[NSString stringWithFormat:@"%C",0x2026]];
	
	//[scratchTextStorage addLayoutManager:scratchLayoutManager];
    [scratchLayoutManager ensureLayoutForCharacterRange:NSMakeRange(charIndex, 1)];
    textFrame = [scratchLayoutManager lineFragmentRectForGlyphAtIndex:[scratchLayoutManager glyphIndexForCharacterAtIndex:charIndex] effectiveRange:&glyphRange];
    
    //cellFrame.origin.x -= NSMinX(textFrame);
    //cellFrame.origin.y -= NSMinY(textFrame);
    
    //[scratchLayoutManager drawGlyphsForGlyphRange:glyphRange atPoint:cellFrame.origin];
	[realLayoutManager ensureLayoutForCharacterRange:NSMakeRange(0, 1)];
	[realLayoutManager drawGlyphsForGlyphRange:NSMakeRange(0, 1) atPoint:cellFrame.origin];
    //[scratchTextStorage removeLayoutManager:scratchLayoutManager];
	
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:lineFoldingEnabled];
    
    [context restoreGraphicsState];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
    NSLayoutManager *layoutManager = [textContainer layoutManager];
    NSTextStorage *textStorage = [layoutManager textStorage];
    NSTextContainer *scratchContainer = [[scratchLayoutManager textContainers] objectAtIndex:0];
    NSRect textFrame;
    NSRange glyphRange;
    NSRect frame;
    BOOL lineFoldingEnabled = [(WCSourceTextStorage *)textStorage lineFoldingEnabled];
	
    if (layoutManager == scratchLayoutManager) return NSZeroRect; // we don't do layout for scratchLayoutManager
	
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:NO];
	
    if ([scratchLayoutManager textStorage] != textStorage) {
        [textStorage addLayoutManager:scratchLayoutManager];
    }
	
    if (!NSEqualSizes([textContainer containerSize], [scratchContainer containerSize])) [scratchContainer setContainerSize:[textContainer containerSize]];
	
	WCFontAndColorTheme *currentTheme = [[WCFontAndColorThemeManager sharedManager] currentTheme];
	
	[scratchTextStorage addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[currentTheme plainTextFont],NSFontAttributeName, nil] range:NSMakeRange(0, [scratchTextStorage length])];
    [scratchLayoutManager ensureLayoutForCharacterRange:NSMakeRange(charIndex, 1)];
	[realLayoutManager ensureLayoutForCharacterRange:NSMakeRange(0, 1)];
    textFrame = [scratchLayoutManager lineFragmentRectForGlyphAtIndex:[scratchLayoutManager glyphIndexForCharacterAtIndex:charIndex] effectiveRange:&glyphRange];
	textFrame.size.width = [realLayoutManager usedRectForTextContainer:realTextContainer].size.width;
	
    [(WCSourceTextStorage *)textStorage setLineFoldingEnabled:lineFoldingEnabled];
	
    frame.origin = NSZeroPoint;
    //frame.size = [[[self class] disclosureTriangleImage] size]; 
	
    //frame.size.width += (HorizontalInset * 2);
    frame.size.height = NSHeight(lineFrag);
	
    frame.origin.y -= [[scratchLayoutManager typesetter] baselineOffsetInLayoutManager:scratchLayoutManager glyphIndex:glyphRange.location];
	
	//[scratchTextStorage removeLayoutManager:scratchLayoutManager];
	
    frame.size.width = NSWidth(textFrame);
    //if (NSWidth(frame) > MaxWidth) frame.size.width = MaxWidth;
	
    return frame;
}
@end
