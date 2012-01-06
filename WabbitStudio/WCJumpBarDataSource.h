//
//  WCJumpBarDataSource.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceScanner;

@protocol WCJumpBarDataSource <NSObject>
@required
- (NSURL *)fileURL;
- (NSString *)displayName;
- (WCSourceScanner *)sourceScanner;
- (NSDocument *)document;
@end
