//
//  WCCompletionChoice.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCSourceToken.h"
#import "WCCompletionItem.h"

@interface WCCompletionChoice : NSObject <WCCompletionItem> {
	NSString *_name;
	NSDictionary *_dictionary;
	WCSourceTokenType _type;
}
@property (readonly,nonatomic) NSDictionary *completionDictionary;
@property (readonly,nonatomic) NSString *name;

+ (id)completionChoiceOfType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary;
- (id)initWithType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary;
@end
