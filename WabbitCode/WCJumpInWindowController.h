//
//  WCJumpInWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>
#import "WCJumpInDataSource.h"

@interface WCJumpInWindowController : NSWindowController <NSControlTextEditingDelegate,NSWindowDelegate> {
	__weak id <WCJumpInDataSource> _dataSource;
	NSArray *_items;
	NSMutableArray *_matches;
	NSString *_searchString;
	NSString *_statusString;
	NSOperationQueue *_operationQueue;
	struct {
		unsigned int searching:1;
		unsigned int RESERVED:31;
	} _jumpInFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *jumpButton;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *cancelButton;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;

@property (readwrite,copy,nonatomic) NSString *searchString;
@property (readwrite,copy,nonatomic) NSString *statusString;
@property (readonly,copy,nonatomic) NSArray *items;
@property (readonly,nonatomic) NSArray *matches;
@property (readonly,nonatomic) NSMutableArray *mutableMatches;
@property (readwrite,assign,nonatomic,getter = isSearching) BOOL searching; 

+ (WCJumpInWindowController *)sharedWindowController;

- (void)showJumpInWindowWithDataSource:(id <WCJumpInDataSource>)dataSource;

- (IBAction)jump:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)search:(id)sender;
@end
