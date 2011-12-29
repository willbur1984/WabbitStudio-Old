//
//  WCSourceSymbol.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCCompletionItem.h"

typedef enum _WCSourceSymbolType {
	WCSourceSymbolTypeLabel,
	WCSourceSymbolTypeEquate,
	WCSourceSymbolTypeDefine,
	WCSourceSymbolTypeMacro
	
} WCSourceSymbolType;

@interface WCSourceSymbol : NSObject <WCCompletionItem> {
	WCSourceSymbolType _type;
	NSRange _range;
	NSString *_name;
}
@property (readonly,nonatomic) WCSourceSymbolType type;
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *typeDescription;
@property (readonly,nonatomic) NSImage *icon;

+ (id)sourceSymbolOfType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
- (id)initWithType:(WCSourceSymbolType)type range:(NSRange)range name:(NSString *)name;
@end
