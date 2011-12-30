//
//  WCEquateSymbol.h
//  WabbitEdit
//
//  Created by William Towe on 12/22/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceSymbol.h"

@interface WCEquateSymbol : WCSourceSymbol <WCCompletionItem,RSToolTipProvider> {
	NSString *_value;
}
@property (readonly,nonatomic) NSString *value;

+ (id)equateSymbolWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value;
// designated initializer
- (id)initWithRange:(NSRange)range name:(NSString *)name value:(NSString *)value;
@end
