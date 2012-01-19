//
//  WCDocument.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>
#import "WCJumpBarDataSource.h"
#import "WCSourceTextStorageDelegate.h"
#import "WCSourceScannerDelegate.h"
#import "WCSourceHighlighterDelegate.h"

extern NSString *const WCSourceFileDocumentWindowFrameKey;
extern NSString *const WCSourceFileDocumentSelectedRangeKey;
extern NSString *const WCSourceFileDocumentStringEncodingKey;
extern NSString *const WCSourceFileDocumentVisibleRangeKey;

@class WCSourceScanner,WCSourceHighlighter,WCSourceTextStorage,WCProjectDocument;

@interface WCSourceFileDocument : NSDocument <WCJumpBarDataSource,WCSourceTextStorageDelegate,WCSourceScannerDelegate,WCSourceHighlighterDelegate> {
	__weak WCProjectDocument *_projectDocument;
	
	NSStringEncoding _fileEncoding;
	
	WCSourceTextStorage *_textStorage;
	WCSourceScanner *_sourceScanner;
	WCSourceHighlighter *_sourceHighlighter;
}

@property (readonly,retain) WCSourceScanner *sourceScanner;
@property (readonly,retain) WCSourceHighlighter *sourceHighlighter;
@property (readonly,retain) WCSourceTextStorage *textStorage;
@property (readwrite,assign) WCProjectDocument *projectDocument;

- (void)reloadDocumentFromDisk;

@end
