//
//  RSFileReference.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"

@interface RSFileReference : RSObject <RSPlistArchiving> {
	NSURL *_fileReferenceURL;
	NSString *_UUID;
}
@property (readonly,nonatomic) NSString *UUID;
@property (readonly,nonatomic) NSURL *fileReferenceURL;
@property (readwrite,copy,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSString *fileName;

+ (RSFileReference *)fileReferenceWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end
