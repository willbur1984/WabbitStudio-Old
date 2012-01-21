//
//  WCLineNumberRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSRulerView.h>

@interface WCLineNumberRulerView : NSRulerView {
	NSMutableArray *_lineStartIndexes;
	BOOL _shouldRecalculateLineStartIndexes;
}
@property (readonly,nonatomic) NSArray *lineStartIndexes;
@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,nonatomic) CGFloat minimumThickness;
@property (readonly,nonatomic) NSDictionary *textAttributes;
@property (readonly,nonatomic) NSColor *backgroundColor;

- (void)drawBackgroundInRect:(NSRect)backgroundRect;
- (void)drawRightMarginInRect:(NSRect)rightMarginRect;
- (void)drawCurrentLineHighlightInRect:(NSRect)rect;
- (void)drawLineNumbersInRect:(NSRect)lineNumbersRect;

- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumbers:(NSIndexSet *)selectedLineNumbers;
@end
