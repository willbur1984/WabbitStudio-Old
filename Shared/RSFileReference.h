//
//  RSFileReference.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import "RSFileReferenceDelegate.h"

/** Allows referencing a file and tracking its movement/modification.
 
 Anything that wants to reference a file should do so through a RSFileReference instance.
 
 */

@class UKKQueue;

@interface RSFileReference : RSObject <RSPlistArchiving,NSFilePresenter,NSCopying> {
	__weak id <RSFileReferenceDelegate> _delegate;
	NSURL *_fileReferenceURL;
	NSURL *_fileURL;
	UKKQueue *_kqueue;
	struct {
		unsigned int ignoreNextFileWatcherNotification:1;
		unsigned int shouldMonitorFile:1;
		unsigned int RESERVED:30;
	} _fileReferenceFlags;
}
@property (readwrite,assign,nonatomic) id <RSFileReferenceDelegate> delegate;
@property (readonly,nonatomic) NSURL *fileReferenceURL;
@property (readwrite,copy,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSString *fileUTI;
@property (readwrite,assign,nonatomic) BOOL ignoreNextFileWatcherNotification;
@property (readonly,nonatomic) NSString *filePath;
@property (readonly,nonatomic) NSURL *parentDirectoryURL;
@property (readwrite,assign,nonatomic) BOOL shouldMonitorFile;

+ (id)fileReferenceWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;

- (void)performCleanup;
@end
