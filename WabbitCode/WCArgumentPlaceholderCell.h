//
//  WCArgumentPlaceholderCell.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextAttachment.h>
#import "WCSourceToken.h"
#import "RSPlistArchiving.h"

extern NSString *const WCPasteboardTypeArgumentPlaceholderCell;

@interface WCArgumentPlaceholderCell : NSTextAttachmentCell <RSPlistArchiving,NSPasteboardItemDataProvider,NSPasteboardWriting> {
	NSArray *_argumentChoices;
	WCSourceTokenType _argumentChoicesType;
}
@property (readonly,nonatomic) NSArray *argumentChoices;
@property (readonly,nonatomic) NSImage *icon;

- (id)initTextCell:(NSString *)aString argumentChoices:(NSArray *)argumentChoices argumentChoicesType:(WCSourceTokenType)argumentChoicesType;
@end
