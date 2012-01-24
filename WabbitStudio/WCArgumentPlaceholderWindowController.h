//
//  WCArgumentPlaceholderWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCArgumentPlaceholderCell;

@interface WCArgumentPlaceholderWindowController : NSWindowController {
	__weak NSTextView *_textView;
	NSUInteger _characterIndex;
	WCArgumentPlaceholderCell *_argumentPlaceholderCell;
	id _eventMonitor;
	id _applicationDidResignActiveObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;

@property (readonly,nonatomic) WCArgumentPlaceholderCell *argumentPlaceholderCell;

+ (WCArgumentPlaceholderWindowController *)argumentPlaceholderWindowControllerWithArgumentPlaceholderCell:(WCArgumentPlaceholderCell *)argumentPlaceholderCell characterIndex:(NSUInteger)characterIndex textView:(NSTextView *)textView;
- (id)initWithArgumentPlaceholderCell:(WCArgumentPlaceholderCell *)argumentPlaceholderCell characterIndex:(NSUInteger)characterIndex textView:(NSTextView *)textView;
@end
