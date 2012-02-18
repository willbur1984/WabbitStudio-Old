//
//  NSArray+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSArray.h>

@class WCSourceToken,WCSourceSymbol,RSBookmark,WCFold,WCBuildIssue,WCFileBreakpoint;

@interface NSArray (WCExtensions)
- (NSUInteger)sourceTokenIndexForRange:(NSRange)range;
- (WCSourceToken *)sourceTokenForRange:(NSRange)range;
- (NSArray *)sourceTokensForRange:(NSRange)range;

- (NSUInteger)sourceSymbolIndexForRange:(NSRange)range;
- (WCSourceSymbol *)sourceSymbolForRange:(NSRange)range;
- (NSArray *)sourceSymbolsForRange:(NSRange)range;

- (NSUInteger)bookmarkIndexForRange:(NSRange)range;
- (RSBookmark *)bookmarkForRange:(NSRange)range;
- (NSArray *)bookmarksForRange:(NSRange)range;

- (NSUInteger)foldIndexForRange:(NSRange)range;
- (WCFold *)foldForRange:(NSRange)range;
- (NSArray *)foldsForRange:(NSRange)range;
- (WCFold *)deepestFoldForRange:(NSRange)range;

- (NSUInteger)buildIssueIndexForRange:(NSRange)range;
- (WCBuildIssue *)buildIssueForRange:(NSRange)range;
- (NSArray *)buildIssuesForRange:(NSRange)range;

- (NSUInteger)fileBreakpointIndexForRange:(NSRange)range;
- (WCFileBreakpoint *)fileBreakpointForRange:(NSRange)range;
- (NSArray *)fileBreakpointsForRange:(NSRange)range;

- (NSUInteger)lineNumberForRange:(NSRange)range;

- (id)firstObject;
@end

@interface NSMutableArray (WCExtensions)
- (void)removeFirstObject;
@end
