//
//  WCScanSymbolsOperation.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>

@class WCSourceScanner;

@interface WCScanSymbolsOperation : NSOperation {
	WCSourceScanner *_sourceScanner;
	NSString *_string;
}
+ (id)scanSymbolsOperationWithSourceScanner:(WCSourceScanner *)sourceScanner;
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;
@end
