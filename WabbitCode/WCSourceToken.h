//
//  WCSourceToken.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/NSObject.h>

typedef enum _WCSourceTokenType {
	WCSourceTokenTypeNone = 0,
	WCSourceTokenTypeRegister,
	WCSourceTokenTypeString,
	WCSourceTokenTypeMneumonic,
	WCSourceTokenTypeNumber,
	WCSourceTokenTypeHexadecimal,
	WCSourceTokenTypeBinary,
	WCSourceTokenTypePreProcessor,
	WCSourceTokenTypeDirective,
	WCSourceTokenTypeConditional,
	WCSourceTokenTypeComment,
	WCSourceTokenTypeMultilineComment
	
} WCSourceTokenType;

extern NSString *const WCSourceTokenTypeAttributeName;

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
