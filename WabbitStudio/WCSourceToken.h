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
	WCSourceTokenTypeRegister = 1,
	WCSourceTokenTypeString = 2,
	WCSourceTokenTypeMneumonic = 3,
	WCSourceTokenTypeNumber = 4,
	WCSourceTokenTypeHexadecimal = 5,
	WCSourceTokenTypeBinary = 6,
	WCSourceTokenTypePreProcessor = 7,
	WCSourceTokenTypeDirective = 8,
	WCSourceTokenTypeConditional = 9
	
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
