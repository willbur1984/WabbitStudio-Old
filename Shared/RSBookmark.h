//
//  RSBookmark.h
//  WabbitStudio
//
//  Created by William Towe on 1/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"

@interface RSBookmark : RSObject <RSPlistArchiving> {
	__weak NSTextStorage *_textStorage;
	NSRange _range;
	NSRange _visibleRange;
}
@property (readonly,nonatomic) NSTextStorage *textStorage;
@property (readonly,assign,nonatomic) NSRange range;
@property (readonly,assign,nonatomic) NSRange visibleRange;
@property (readonly,nonatomic) NSUInteger lineNumber;

+ (RSBookmark *)bookmarkWithRange:(NSRange)range visibleRange:(NSRange)visibleRange textStorage:(NSTextStorage *)textStorage;
- (id)initWithRange:(NSRange)range visibleRange:(NSRange)visibleRange textStorage:(NSTextStorage *)textStorage;
@end
