//
//  WCScanFoldsOperation.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>

@class WCSourceScanner;

@interface WCScanFoldsOperation : NSOperation {
	WCSourceScanner *_sourceScanner;
	NSString *_string;
}
+ (WCScanFoldsOperation *)scanFoldsOperationWithSourceScanner:(WCSourceScanner *)sourceScanner;
- (id)initWithSourceScanner:(WCSourceScanner *)sourceScanner;
@end
