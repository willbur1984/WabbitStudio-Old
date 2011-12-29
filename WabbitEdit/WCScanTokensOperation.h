//
//  WCScanTokensOperation.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>

@class WCSourceScanner;

@interface WCScanTokensOperation : NSOperation {
	WCSourceScanner *_scanner;
	NSString *_string;
}
+ (id)scanTokensOperationWithScanner:(WCSourceScanner *)scanner;
- (id)initWithScanner:(WCSourceScanner *)scanner;
@end
