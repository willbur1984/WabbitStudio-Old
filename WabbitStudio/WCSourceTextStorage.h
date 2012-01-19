//
//  WCSourceTextStorage.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextStorage.h>
#import "WCSourceTextStorageDelegate.h"

@interface WCSourceTextStorage : NSTextStorage {
	__weak id <WCSourceTextStorageDelegate> _delegate;
	NSMutableAttributedString *_attributedString;
	NSMutableArray *_lineStartIndexes;
}
@property (readonly,nonatomic) NSArray *lineStartIndexes;
@property (readwrite,assign,nonatomic) id <WCSourceTextStorageDelegate> delegate;
@property (readonly,nonatomic) NSParagraphStyle *paragraphStyle;

+ (NSParagraphStyle *)defaultParagraphStyle;
@end
