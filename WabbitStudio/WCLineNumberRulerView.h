//
//  WCLineNumberRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSRulerView.h>

/** Handles drawing line numbers and highlighting the current line for its corresponding text view.
 
 This is based on NoodleLineNumberView, which can be found at http://www.noodlesoft.com/blog/2008/10/05/displaying-line-numbers-with-nstextview/
 The starting character index for each line in the text is stored in `_lineStartIndexes`, we consult this information to draw a range of line numbers, determined by the text view's bounds. The property `lineStartIndexes` is meant to be overridden by subclasses if there is a shared array that needs to be used. This is done in WCSourceRulerView, which uses the line information stored in WCSourceTextStorage instead of its own. This way, not every ruler view maintains a copy of the line information unecessarily.
 
 */

@interface WCLineNumberRulerView : NSRulerView {
	NSMutableArray *_lineStartIndexes;
	BOOL _shouldRecalculateLineStartIndexes;
}
/** Accessor for the `_lineStartIndexes` array of starting line indexes.
 
 This just returns an autoreleased copy of `_lineStartIndexes`.
 
 */
@property (readonly,nonatomic) NSArray *lineStartIndexes;

/** Accessor for our text view 
 
 This just returns `[self clientView]`.
 
 */
@property (readonly,nonatomic) NSTextView *textView;

/** Returns the minimum thickness required to display all our line numbers. 
 
 Currently, just returns the greater value between _DEFAULT_THICKNESS_ and the width of a string filled with 8's corresponding to the greatest line number we may have to display plus our _RULER_MARGIN_. Subclassses can override this to return a larger width, but should always add their additional required width to super's result (i.e. `return [super minimumThickness]+kMyMinimumThickness`).
 
 */
@property (readonly,nonatomic) CGFloat minimumThickness;

/** Accessor for our default text attributes that are used to draw each line number. */
@property (readonly,nonatomic) NSDictionary *textAttributes;

/** Accessor for our background color. 
 
 Currently returns a background color that matches Xcode's.
 
 */
@property (readonly,nonatomic) NSColor *backgroundColor;

/** @name Public Methods */

/** Draws our background in _backgroundRect_.
 
 Currently just sets our `backgroundColor` as the fill color and fills _backgroundRect_ with it
 
 @param backgroundRect The rect in which to draw our background.
 
 */
- (void)drawBackgroundInRect:(NSRect)backgroundRect;

/** Draws the right margin divider line in _rightMarginRect_.
 
 Currently draw a dotted line line along the right edge of _rightMarginRect_.
 
 @param rightMarginRect The rect in which to draw the right margin divider line.
 
 */
- (void)drawRightMarginInRect:(NSRect)rightMarginRect;

/** Draws the current line highlight (if enabled in user defaults).
 
 Currently takes the current line highlight color, fills a rectangle the encloses the selected range of our text view with a slightly transparent version of that color then fills top and bottom 1 pixel tall rectangles with the color itself to border the filled rect.
 
 @param currentLineHighlightRect The rect in which to draw our current line highlight.
 
 */
- (void)drawCurrentLineHighlightInRect:(NSRect)currentLineHighlightRect;

/** Draws the line numbers for the visible part of our text view in _lineNumbersRect_.
 
 @param lineNumbersRect The rect in which to draw our visible line numbers.
 
 */
- (void)drawLineNumbersInRect:(NSRect)lineNumbersRect;

/** Provides the attributes that should be used for _lineNumber_ given the _selectedLineNumbers_.
 
 @param lineNumber The line number that the attributes will be applied to.
 @param selectedLineNumbers An index set of selected line numbers you can use to compare against _lineNumber_.
 @return A dictionary of text attributes to apply to the line number string for _lineNumber_.
 
 */
- (NSDictionary *)textAttributesForLineNumber:(NSUInteger)lineNumber selectedLineNumbers:(NSIndexSet *)selectedLineNumbers;
@end
