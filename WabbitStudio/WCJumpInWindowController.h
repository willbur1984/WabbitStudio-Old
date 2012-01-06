//
//  WCJumpInWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "WCJumpInDataSource.h"

@interface WCJumpInWindowController : NSWindowController <NSControlTextEditingDelegate> {
	__weak id <WCJumpInDataSource> _dataSource;
	NSArray *_items;
	NSMutableArray *_matches;
	NSString *_searchString;
	NSString *_statusString;
	NSOperationQueue *_operationQueue;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *jumpButton;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *cancelButton;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;

@property (readwrite,copy,nonatomic) NSString *searchString;
@property (readonly,copy,nonatomic) NSString *statusString;
@property (readonly,copy,nonatomic) NSArray *items;
@property (readonly,nonatomic) NSArray *matches;
@property (readonly,nonatomic) NSMutableArray *mutableMatches;

+ (WCJumpInWindowController *)sharedWindowController;

- (void)showJumpInWindowWithDataSource:(id <WCJumpInDataSource>)dataSource;

- (IBAction)jump:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)search:(id)sender;
@end
