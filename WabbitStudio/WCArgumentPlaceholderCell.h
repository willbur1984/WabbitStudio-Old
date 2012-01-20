//
//  WCArgumentPlaceholderCell.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextAttachment.h>
#import "WCSourceToken.h"

@interface WCArgumentPlaceholderCell : NSTextAttachmentCell {
	NSArray *_argumentChoices;
	WCSourceTokenType _argumentChoicesType;
}
@property (readonly,nonatomic) NSArray *argumentChoices;
@property (readonly,nonatomic) WCSourceTokenType argumentChoicesType;

- (id)initTextCell:(NSString *)aString argumentChoices:(NSArray *)argumentChoices argumentChoicesType:(WCSourceTokenType)argumentChoicesType;
@end
