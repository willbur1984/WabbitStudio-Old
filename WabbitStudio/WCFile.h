//
//  WCFile.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import "WCOpenQuicklyItem.h"
#import "WCFileDelegate.h"
#import <Quartz/Quartz.h>

@class RSFileReference,WCProject;

@interface WCFile : RSObject <RSPlistArchiving,WCOpenQuicklyItem,QLPreviewItem> {
	__weak id <WCFileDelegate> _delegate;
	RSFileReference *_fileReference;
}
@property (readwrite,assign,nonatomic) id <WCFileDelegate> delegate;
@property (readonly,nonatomic) RSFileReference *fileReference;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSString *fileUTI;

+ (id)fileWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end
