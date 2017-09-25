//
//  RSFileReference.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSObject.h"
#import "RSFileReferenceDelegate.h"

/** Allows referencing a file and tracking its movement/modification.
 
 Anything that wants to reference a file should do so through a RSFileReference instance.
 
 */

@class UKKQueue;

@interface RSFileReference : RSObject <RSPlistArchiving,NSFilePresenter,NSCopying> {
	__unsafe_unretained id <RSFileReferenceDelegate> _delegate;
	NSURL *_fileReferenceURL;
	NSURL *_fileURL;
	UKKQueue *_kqueue;
	NSOperationQueue *_operationQueue;
	struct {
		unsigned int ignoreNextFileWatcherNotification:1;
		unsigned int shouldMonitorFile:1;
		unsigned int RESERVED:30;
	} _fileReferenceFlags;
}
@property (readwrite,assign,nonatomic) id <RSFileReferenceDelegate> delegate;
@property (readonly,nonatomic) NSURL *fileReferenceURL;
@property (readwrite,copy) NSURL *fileURL;
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
