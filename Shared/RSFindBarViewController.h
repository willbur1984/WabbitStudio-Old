//
//  RSFindBarViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSFindOptionsViewControllerDelegate.h"

typedef enum _RSFindBarViewControllerViewMode {
	RSFindBarViewControllerViewModeFind = 0,
	RSFindBarViewControllerViewModeFindAndReplace = 1
	
} RSFindBarViewControllerViewMode;

@interface RSFindBarViewController : NSViewController <RSFindOptionsViewControllerDelegate,NSAnimationDelegate,NSControlTextEditingDelegate> {
	__weak NSTextView *_textView;
	RSFindBarViewControllerViewMode _viewMode;
	NSString *_findString;
	NSString *_replaceString;
	NSRegularExpression *_findRegularExpression;
	NSString *_statusString;
	NSPointerArray *_findRanges;
	NSViewAnimation *_showFindBarAnimation;
	NSViewAnimation *_hideFindBarAnimation;
	NSViewAnimation *_showReplaceControlsAnimation;
	NSViewAnimation *_hideReplaceControlsAnimation;
	RSFindOptionsViewController *_findOptionsViewController;
	id _textStorageDidProcessEditingObservingToken;
	id _viewBoundsDidChangeObservingToken;
	id _windowDidResizeObservingToken;
	NSTimer *_textStorageDidProcessEditingTimer;
	struct {
		unsigned int runShowReplaceControlsAnimationAfterShowFindBarAnimationCompletes:1;
		unsigned int RESERVED:31;
	} _findFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSTextField *replaceTextField;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *replaceAllButton;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *replaceButton;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *replaceAndFindButton;

@property (readonly,nonatomic) NSTextView *textView;
@property (readonly,assign,nonatomic) RSFindBarViewControllerViewMode viewMode;
@property (readwrite,copy,nonatomic) NSString *findString;
@property (readwrite,copy,nonatomic) NSString *replaceString;
@property (readonly,copy,nonatomic) NSString *statusString;
@property (readonly,assign,nonatomic) BOOL wrapAround;
@property (readonly,nonatomic,getter = isFindBarVisible) BOOL findBarVisible;
@property (readonly,assign,nonatomic,getter = areReplaceControlsVisible) BOOL replaceControlsVisible;

- (id)initWithTextView:(NSTextView *)textView;

- (IBAction)toggleFindBar:(id)sender;
- (IBAction)showFindBar:(id)sender;
- (IBAction)hideFindBar:(id)sender;

- (IBAction)toggleReplaceControls:(id)sender;
- (IBAction)showReplaceControls:(id)sender;
- (IBAction)hideReplaceControls:(id)sender;

- (IBAction)toggleFindOptions:(id)sender;
- (IBAction)showFindOptions:(id)sender;
- (IBAction)hideFindOptions:(id)sender;

- (IBAction)find:(id)sender;
- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;
- (IBAction)findNextOrPrevious:(NSSegmentedControl *)sender;

- (IBAction)replaceAll:(id)sender;
- (IBAction)replace:(id)sender;
- (IBAction)replaceAndFind:(id)sender;

- (void)performCleanup;

@end
