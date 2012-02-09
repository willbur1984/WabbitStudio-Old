//
//  NSURL+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RSExtensions)
- (NSImage *)fileIcon;
- (NSString *)fileName;
- (BOOL)isDirectory;
- (BOOL)isPackage;
- (NSURL *)parentDirectoryURL;
- (NSString *)fileUTI;
- (NSString *)filePath;
- (NSDate *)modificationDate;
@end
