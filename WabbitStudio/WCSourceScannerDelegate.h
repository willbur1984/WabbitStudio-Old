//
//  WCSourceScannerDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceScanner;

@protocol WCSourceScannerDelegate <NSObject>
@required
- (NSString *)fileDisplayNameForSourceScanner:(WCSourceScanner *)scanner;
@end
