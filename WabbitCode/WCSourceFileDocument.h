//
//  WCDocument.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

@interface WCSourceFileDocument : NSDocument <WCJumpBarDataSource,WCSourceTextStorageDelegate,WCSourceScannerDelegate,WCSourceHighlighterDelegate,NSTextViewDelegate> {
	__unsafe_unretained WCProjectDocument *_projectDocument;
	
	NSStringEncoding _fileEncoding;
	
	WCSourceTextStorage *_textStorage;
	WCSourceScanner *_sourceScanner;
	WCSourceHighlighter *_sourceHighlighter;
	
	NSTextView *_undoTextView;
}

@property (readonly,retain) WCSourceScanner *sourceScanner;
@property (readonly,retain) WCSourceHighlighter *sourceHighlighter;
@property (readonly,retain) WCSourceTextStorage *textStorage;
@property (readwrite,assign) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) NSTextView *undoTextView;

- (void)reloadDocumentFromDisk;

@end
