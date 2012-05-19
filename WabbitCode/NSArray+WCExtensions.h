//
//  NSArray+WCExtensions.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
- (NSUInteger)lineStartIndexForRange:(NSRange)range;

- (id)firstObject;
@end

@interface NSMutableArray (WCExtensions)
- (void)removeFirstObject;
@end
