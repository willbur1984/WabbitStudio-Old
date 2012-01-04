//
//  RSFindBarViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSFindOptionsViewControllerDelegate.h"

@interface RSFindBarViewController : NSViewController <RSFindOptionsViewControllerDelegate,NSAnimationDelegate,NSControlTextEditingDelegate> {
	__weak NSTextView *_textView;
	NSString *_findString;
	NSString *_lastFindString;
	NSRegularExpression *_findRegularExpression;
	NSString *_statusString;
	NSPointerArray *_findRanges;
	NSViewAnimation *_showFindBarAnimation;
	NSViewAnimation *_hideFindBarAnimation;
	RSFindOptionsViewController *_findOptionsViewController;
	id _textStorageDidProcessEditingObservingToken;
	struct {
		unsigned int wrapAround:1;
		unsigned int RESERVED:31;
	} _findFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,copy,nonatomic) NSString *findString;
@property (readonly,copy,nonatomic) NSString *statusString;
@property (readonly,assign,nonatomic) BOOL wrapAround;
@property (readonly,nonatomic,getter = isFindBarVisible) BOOL findBarVisible;

- (id)initWithTextView:(NSTextView *)textView;

- (IBAction)toggleFindBar:(id)sender;
- (IBAction)showFindBar:(id)sender;
- (IBAction)hideFindBar:(id)sender;

- (IBAction)showFindOptions:(id)sender;

- (IBAction)find:(id)sender;
- (IBAction)findNext:(id)sender;
- (IBAction)findPrevious:(id)sender;
- (IBAction)findNextOrPrevious:(NSSegmentedControl *)sender;

+ (NSDictionary *)findTextAttributes;

@end
