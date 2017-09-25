//
//  WCSourceTextStorage.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <AppKit/NSTextStorage.h>
#import "WCSourceTextStorageDelegate.h"

extern NSString *const WCSourceTextStorageDidAddBookmarkNotification;
extern NSString *const WCSourceTextStorageDidRemoveBookmarkNotification;
extern NSString *const WCSourceTextStorageDidRemoveAllBookmarksNotification;

extern NSString *const WCSourceTextStorageDidFoldNotification;
extern NSString *const WCSourceTextStorageDidUnfoldNotification;
extern NSString *const WCSourceTextStorageFoldRangeUserInfoKey;

@class RSBookmark;

@interface WCSourceTextStorage : NSTextStorage {
	__unsafe_unretained id <WCSourceTextStorageDelegate> _delegate;
	NSMutableAttributedString *_attributedString;
	NSMutableArray *_lineStartIndexes;
	NSMutableArray *_bookmarks;
	struct {
		unsigned int lineFoldingEnabled:1;
		unsigned int RESERVED:31;
	} _textStorageFlags;
}
@property (readonly,nonatomic) NSArray *lineStartIndexes;
@property (readwrite,assign,nonatomic) id <WCSourceTextStorageDelegate> delegate;
@property (readonly,nonatomic) NSParagraphStyle *paragraphStyle;
@property (readonly,nonatomic) NSArray *bookmarks;
@property (readwrite,assign,nonatomic) BOOL lineFoldingEnabled;

+ (NSParagraphStyle *)defaultParagraphStyle;

- (void)addBookmark:(RSBookmark *)bookmark;
- (void)removeBookmark:(RSBookmark *)bookmark;
- (void)removeAllBookmarks;
- (RSBookmark *)bookmarkAtLineNumber:(NSUInteger)lineNumber;
- (NSArray *)bookmarksForRange:(NSRange)range;

- (void)foldRange:(NSRange)range;
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange;
- (NSRange)foldRangeForRange:(NSRange)range;
@end
