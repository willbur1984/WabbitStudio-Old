//
//  WCCompletionWindowController.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSTableViewDelegate.h"

@class WCSourceTextView,NDMutableTrie;

@interface WCCompletionWindowController : NSWindowController <RSTableViewDelegate> {
	__weak WCSourceTextView *_textView;
	NSMutableArray *_completions;
	id _eventMonitor;
	id _applicationDidResignActiveObservingToken;
	NDMutableTrie *_mneumonicCompletions;
	NDMutableTrie *_preProcessorCompletions;
	NDMutableTrie *_registerCompletions;
	NDMutableTrie *_conditionalCompletions;
	NDMutableTrie *_directiveCompletions;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readonly,nonatomic) WCSourceTextView *textView;
@property (readonly,nonatomic) NSArray *completions;

+ (WCCompletionWindowController *)sharedWindowController;
- (void)showCompletionWindowControllerForSourceTextView:(WCSourceTextView *)textView;
@end
