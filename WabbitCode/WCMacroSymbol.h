//
//  WCMacroSymbol.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceSymbol.h"

@interface WCMacroSymbol : WCSourceSymbol <WCCompletionItem> {
	NSString *_value;
	NSRange _valueRange;
	NSArray *_arguments;
	NSAttributedString *_attributedValueString;
}
@property (readonly,nonatomic) NSString *value;
@property (readonly,nonatomic) NSRange valueRange;
@property (readonly,nonatomic) NSArray *arguments;
@property (readonly,nonatomic) NSSet *argumentsSet;

+ (id)macroSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value valueRange:(NSRange)valueRange arguments:(NSArray *)arguments;
// designated initializer
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value valueRange:(NSRange)valueRange arguments:(NSArray *)arguments;

+ (id)macroSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value valueRange:(NSRange)valueRange;
@end
