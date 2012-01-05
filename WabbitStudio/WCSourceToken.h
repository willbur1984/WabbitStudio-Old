//
//  WCSourceToken.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

typedef enum _WCSourceTokenType {
	WCSourceTokenTypeComment = 0,
	WCSourceTokenTypeRegister,
	WCSourceTokenTypeString,
	WCSourceTokenTypeMneumonic,
	WCSourceTokenTypeNumber,
	WCSourceTokenTypeHexadecimal,
	WCSourceTokenTypeBinary,
	WCSourceTokenTypePreProcessor,
	WCSourceTokenTypeDirective,
	WCSourceTokenTypeConditional
	
} WCSourceTokenType;

@interface WCSourceToken : NSObject {
	WCSourceTokenType _type;
	NSRange _range;
	NSString *_name;
}
@property (readonly,nonatomic) WCSourceTokenType type;
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *typeDescription;
@property (readonly,nonatomic) NSImage *icon;

+ (id)sourceTokenOfType:(WCSourceTokenType)type range:(NSRange)range name:(NSString *)name;
- (id)initWithType:(WCSourceTokenType)type range:(NSRange)range name:(NSString *)name;

+ (NSImage *)sourceTokenIconForSourceTokenType:(WCSourceTokenType)sourceTokenType;
@end
