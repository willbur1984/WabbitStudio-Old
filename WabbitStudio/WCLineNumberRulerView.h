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
	id _windowDidResizeObservingToken;
}
@property (readonly,nonatomic) NSArray *lineStartIndexes;
@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,nonatomic) CGFloat minimumThickness;
@property (readonly,nonatomic) NSDictionary *textAttributes;

- (void)drawBackgroundAndDividerLineInRect:(NSRect)backgroundAndDividerLineRect;
- (void)drawCurrentLineHighlightInRect:(NSRect)rect;
- (void)drawLineNumbersInRect:(NSRect)lineNumbersRect;

- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumber:(NSUInteger)selectedLineNumber;
@end
