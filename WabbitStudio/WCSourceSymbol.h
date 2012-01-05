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

typedef enum _WCSourceSymbolType {
	WCSourceSymbolTypeLabel,
	WCSourceSymbolTypeEquate,
	WCSourceSymbolTypeDefine,
	WCSourceSymbolTypeMacro
	
} WCSourceSymbolType;

@class WCSourceScanner;

@interface WCSourceSymbol : NSObject <WCCompletionItem,RSToolTipProvider> {
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

+ (id)sourceSymbolOfType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
- (id)initWithType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
@end
