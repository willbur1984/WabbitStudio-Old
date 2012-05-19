//
//  WCSourceSymbol.h
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
#import "WCCompletionItem.h"
#import "RSToolTipProvider.h"
#import "WCJumpInItem.h"
#import "WCOpenQuicklyItem.h"

typedef enum _WCSourceSymbolType {
	WCSourceSymbolTypeNone = 0,
	WCSourceSymbolTypeLabel,
	WCSourceSymbolTypeEquate,
	WCSourceSymbolTypeDefine,
	WCSourceSymbolTypeMacro
	
} WCSourceSymbolType;

extern NSString *const WCSourceSymbolTypeAttributeName;

@class WCSourceScanner;

@interface WCSourceSymbol : NSObject <WCCompletionItem,RSToolTipProvider,WCJumpInItem,WCOpenQuicklyItem> {
	__weak WCSourceScanner *_sourceScanner;
	WCSourceSymbolType _type;
	NSRange _range;
	NSString *_name;
}
@property (readwrite,assign,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCSourceSymbolType type;
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *typeDescription;
@property (readonly,nonatomic) NSImage *icon;
@property (readonly,nonatomic) NSUInteger lineNumber;
@property (readonly,nonatomic) NSString *nameAndLineNumber;
@property (readonly,nonatomic) NSString *toolTip;

+ (id)sourceSymbolOfType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
- (id)initWithType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
@end
