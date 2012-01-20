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
#import "RSFileReferenceDelegate.h"
#import <Quartz/Quartz.h>

@class RSFileReference,WCProject;

@interface WCFile : RSObject <RSPlistArchiving,WCOpenQuicklyItem,RSFileReferenceDelegate,QLPreviewItem> {
	__weak id <WCFileDelegate> _delegate;
	RSFileReference *_fileReference;
	struct {
		unsigned int edited:1;
		unsigned int RESERVED:31;
	} _fileFlags;
}
@property (readwrite,assign,nonatomic) id <WCFileDelegate> delegate;
@property (readonly,nonatomic) RSFileReference *fileReference;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSString *fileUTI;
@property (readwrite,assign,nonatomic,getter = isEdited) BOOL edited;
@property (readonly,nonatomic) NSString *filePath;

+ (id)fileWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end