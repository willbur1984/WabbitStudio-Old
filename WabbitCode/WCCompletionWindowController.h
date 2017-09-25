//
//  WCCompletionWindowController.h
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

#import <AppKit/NSWindowController.h>
#import "RSTableViewDelegate.h"

@class WCSourceTextView,NDMutableTrie;

@interface WCCompletionWindowController : NSWindowController <RSTableViewDelegate> {
	__unsafe_unretained WCSourceTextView *_textView;
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
