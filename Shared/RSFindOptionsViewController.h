//
//  RSFindOptionsViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <AppKit/NSViewController.h>
#import "RSFindOptionsViewControllerDelegate.h"

typedef enum _RSFindOptionsFindStyle {
	RSFindOptionsFindStyleTextual = 0,
	RSFindOptionsFindStyleRegularExpression = 1
	
} RSFindOptionsFindStyle;

typedef enum _RSFindOptionsMatchStyle {
	RSFindOptionsMatchStyleContains = 0,
	RSFindOptionsMatchStyleStartsWith = 1,
	RSFindOptionsMatchStyleEndsWith = 2,
	RSFindOptionsMatchStyleWholeWord = 3
	
} RSFindOptionsMatchStyle;

@interface RSFindOptionsViewController : NSViewController <NSPopoverDelegate> {
	__weak id <RSFindOptionsViewControllerDelegate> _delegate;
	RSFindOptionsFindStyle _findStyle;
	RSFindOptionsMatchStyle _matchStyle;
	NSPopover *_popover;
	struct {
		unsigned int matchCase:1;
		unsigned int anchorsMatchLines:1;
		unsigned int dotMatchesNewlines:1;
		unsigned int wrapAround:1;
		unsigned int wrapAroundEnabled:1;
		unsigned int regexOptionsEnabled:1;
		unsigned int RESERVED:26;
	} _findFlags;
}
@property (readwrite,assign,nonatomic) id <RSFindOptionsViewControllerDelegate> delegate;
@property (readwrite,assign,nonatomic) RSFindOptionsFindStyle findStyle;
@property (readwrite,assign,nonatomic) RSFindOptionsMatchStyle matchStyle;
@property (readwrite,assign,nonatomic) BOOL matchCase;
@property (readwrite,assign,nonatomic) BOOL anchorsMatchLines;
@property (readwrite,assign,nonatomic) BOOL dotMatchesNewlines;
@property (readwrite,assign,nonatomic) BOOL wrapAround;
@property (readwrite,assign,nonatomic) BOOL wrapAroundEnabled;
@property (readwrite,assign,nonatomic) BOOL regexOptionsEnabled;
@property (readonly,nonatomic,getter = areFindOptionsVisible) BOOL findOptionsVisible;

- (void)showFindOptionsViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)hideFindOptionsView;

@end
