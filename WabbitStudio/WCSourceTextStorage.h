//
//  WCSourceTextStorage.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextStorage.h>
#import "WCSourceTextStorageDelegate.h"

@class RSBookmark;

@interface WCSourceTextStorage : NSTextStorage {
	__weak id <WCSourceTextStorageDelegate> _delegate;
	NSMutableAttributedString *_attributedString;
	NSMutableArray *_lineStartIndexes;
	NSMutableArray *_bookmarks;
}
@property (readonly,nonatomic) NSArray *lineStartIndexes;
@property (readwrite,assign,nonatomic) id <WCSourceTextStorageDelegate> delegate;
@property (readonly,nonatomic) NSParagraphStyle *paragraphStyle;
@property (readonly,nonatomic) NSArray *bookmarks;

+ (NSParagraphStyle *)defaultParagraphStyle;

- (void)addBookmark:(RSBookmark *)bookmark;
- (void)removeBookmark:(RSBookmark *)bookmark;
- (RSBookmark *)bookmarkAtLineNumber:(NSUInteger)lineNumber;
- (NSArray *)bookmarksForRange:(NSRange)range;
@end
