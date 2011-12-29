//
//  WCMiscellaneousPerformer.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@interface WCMiscellaneousPerformer : NSObject
+ (WCMiscellaneousPerformer *)sharedPerformer;

- (NSURL *)applicationSupportDirectoryURL;

- (NSURL *)applicationFontAndColorThemesDirectoryURL;
- (NSURL *)userFontAndColorThemesDirectoryURL;
@end
