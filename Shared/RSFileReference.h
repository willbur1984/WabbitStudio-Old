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

@interface RSFileReference : RSObject <RSPlistArchiving> {
	__weak id <RSFileReferenceDelegate> _delegate;
	NSURL *_fileReferenceURL;
	NSURL *_fileURL;
	NSString *_UUID;
	UKKQueue *_kqueue;
}
@property (readonly,nonatomic) NSString *UUID;
@property (readonly,nonatomic) NSURL *fileReferenceURL;
@property (readwrite,copy,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSString *fileUTI;
@property (readwrite,assign,nonatomic) id <RSFileReferenceDelegate> delegate;

+ (RSFileReference *)fileReferenceWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end
