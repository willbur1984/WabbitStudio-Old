//
//  WCSourceSymbol.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
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
