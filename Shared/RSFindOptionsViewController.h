//
//  RSFindOptionsViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
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
		unsigned int RESERVED:29;
	} _findFlags;
}
@property (readwrite,assign,nonatomic) id <RSFindOptionsViewControllerDelegate> delegate;
@property (readwrite,assign,nonatomic) RSFindOptionsFindStyle findStyle;
@property (readwrite,assign,nonatomic) RSFindOptionsMatchStyle matchStyle;
@property (readwrite,assign,nonatomic) BOOL matchCase;
@property (readwrite,assign,nonatomic) BOOL anchorsMatchLines;
@property (readwrite,assign,nonatomic) BOOL dotMatchesNewlines;
@property (readonly,nonatomic,getter = areFindOptionsVisible) BOOL findOptionsVisible;

- (void)showFindOptionsViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)hideFindOptionsView;

@end
