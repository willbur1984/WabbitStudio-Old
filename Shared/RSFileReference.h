//
//  RSFileReference.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import "RSFileReferenceDelegate.h"

@class UKKQueue;

/** @brief Allows referencing a file and tracking its movement/modification.
 
 Anything that wants to reference a file should do so through a RSFileReference instance. Uses the excellent UKKQueue class to watch its path and report changes to the tracked file to its delegate.
 
 */

@interface RSFileReference : RSObject <RSPlistArchiving> {
	__weak id <RSFileReferenceDelegate> _delegate;
	NSURL *_fileReferenceURL;
	NSURL *_fileURL;
	NSString *_UUID;
	UKKQueue *_kqueue;
	struct {
		unsigned int ignoreNextFileWatcherNotification:1;
		unsigned int RESERVED:31;
	} _fileReferenceFlags;
}
@property (readwrite,assign,nonatomic) id <RSFileReferenceDelegate> delegate;
@property (readonly,nonatomic) NSString *UUID;
@property (readonly,nonatomic) NSURL *fileReferenceURL;
@property (readwrite,copy,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSString *fileUTI;
@property (readwrite,assign,nonatomic) BOOL ignoreNextFileWatcherNotification;
@property (readonly,nonatomic) NSString *filePath;

+ (RSFileReference *)fileReferenceWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;

@end