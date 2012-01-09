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

@class WCSourceScanner,WCSourceHighlighter,WCSourceTextStorage;

@interface WCSourceFileDocument : NSDocument <WCJumpBarDataSource,WCSourceTextStorageDelegate,WCSourceScannerDelegate,NSWindowDelegate,NSSplitViewDelegate> {
	NSString *_fileContents;
	NSStringEncoding _fileEncoding;
	
	WCSourceTextStorage *_textStorage;
	WCSourceScanner *_sourceScanner;
	WCSourceHighlighter *_sourceHighlighter;
}

@property (readonly,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCSourceHighlighter *sourceHighlighter;
@property (readonly,nonatomic) WCSourceTextStorage *textStorage;

@end
