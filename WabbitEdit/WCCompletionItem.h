//
//  WCCompletionItem.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

static NSString *const WCCompletionItemVariantsKey = @"variants";
static NSString *const WCCompletionItemVariantNameKey = @"name";
static NSString *const WCCompletionItemShortDescriptionKey = @"shortDescription";
static NSString *const WCCompletionItemLongDescriptionKey = @"longDescription";
static NSString *const WCCompletionItemArgumentsKey = @"arguments";
static NSString *const WCCompletionItemArgumentNameKey = @"name";
static NSString *const WCCompletionItemArgumentIsPlaceholderKey = @"isPlaceholder";
static NSString *const WCCompletionItemSubArgumentsKey = @"subArguments";
static NSString *const WCCompletionItemRequiresTrailingNewlineKey = @"requiresTrailingNewline";

@protocol WCCompletionItem <NSObject>
@required
- (NSString *)completionName;
- (NSString *)completionInsertionName;
- (NSImage *)completionIcon;
@optional
- (NSArray *)completionArguments;
- (NSDictionary *)completionDictionary;
@end
