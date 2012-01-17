//
//  WCOpenQuicklyItem.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceFileDocument;

@protocol WCOpenQuicklyItem <NSObject>
@required
- (NSString *)openQuicklyName;
- (NSImage *)openQuicklyImage;
- (NSURL *)openQuicklyLocationURL;
- (NSRange)openQuicklyRange;
- (NSURL *)openQuicklyFileURL;
- (WCSourceFileDocument *)openQuicklySourceFileDocument;
@end
