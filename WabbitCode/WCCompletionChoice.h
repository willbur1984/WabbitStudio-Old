//
//  WCCompletionChoice.h
//  WabbitEdit
//
//  Created by William Towe on 12/24/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
@property (readonly,nonatomic) WCSourceTokenType type;

+ (id)completionChoiceOfType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary;
- (id)initWithType:(WCSourceTokenType)type name:(NSString *)name dictionary:(NSDictionary *)dictionary;
@end
