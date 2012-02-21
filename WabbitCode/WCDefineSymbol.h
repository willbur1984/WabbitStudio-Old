//
//  WCDefineSymbol.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceSymbol.h"

@interface WCDefineSymbol : WCSourceSymbol <WCCompletionItem,RSToolTipProvider> {
	NSString *_value;
	NSArray *_arguments;
	NSAttributedString *_attributedValueString;
}
@property (readonly,nonatomic) NSString *value;
@property (readonly,nonatomic) NSArray *arguments;

+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments;
// designated initializer
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value arguments:(NSArray *)arguments;

+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name;
+ (id)defineSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value;
@end
