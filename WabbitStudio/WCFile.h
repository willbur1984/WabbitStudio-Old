//
//  WCFile.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import <Quartz/Quartz.h>

@class RSFileReference;

@interface WCFile : RSObject <RSPlistArchiving,QLPreviewItem> {
	RSFileReference *_fileReference;
}
@property (readonly,nonatomic) RSFileReference *fileReference;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSURL *fileURL;

+ (id)fileWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end
