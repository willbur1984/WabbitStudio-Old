//
//  WCFileDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCFile,WCSourceFileDocument;

@protocol WCFileDelegate <NSObject>
@required
- (NSURL *)locationURLForFile:(WCFile *)file;
- (WCSourceFileDocument *)sourceFileDocumentForFile:(WCFile *)file;
@end
