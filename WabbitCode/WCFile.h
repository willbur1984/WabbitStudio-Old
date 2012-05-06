//
//  WCFile.h
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
#import "WCOpenQuicklyItem.h"
#import "WCFileDelegate.h"
#import "RSFileReferenceDelegate.h"
#import "WCCompletionItem.h"
#import <Quartz/Quartz.h>

extern NSString *const WCPasteboardTypeFileUUID;

extern NSString *const WCFileUUIDKey;

@class RSFileReference,WCProject;

@interface WCFile : RSObject <RSPlistArchiving,WCOpenQuicklyItem,WCCompletionItem,RSFileReferenceDelegate,QLPreviewItem,NSPasteboardWriting> {
	__weak id <WCFileDelegate> _delegate;
	NSString *_UUID;
	RSFileReference *_fileReference;
	struct {
		unsigned int edited:1;
		unsigned int errors:1;
		unsigned int warnings:1;
		unsigned int RESERVED:29;
	} _fileFlags;
}
@property (readwrite,assign,nonatomic) id <WCFileDelegate> delegate;
@property (readonly,nonatomic) RSFileReference *fileReference;
@property (readwrite,copy,nonatomic) NSString *fileName;
@property (readonly,nonatomic) NSImage *fileIcon;
@property (readonly,nonatomic) NSURL *fileURL;
@property (readonly,nonatomic) NSString *fileUTI;
@property (readwrite,assign,nonatomic,getter = isEdited) BOOL edited;
@property (readonly,nonatomic) NSString *filePath;
@property (readonly,nonatomic,getter = isSourceFile) BOOL sourceFile;
@property (readonly,nonatomic) NSURL *parentDirectoryURL;
@property (readonly,nonatomic) NSString *UUID;
@property (readwrite,assign,nonatomic,getter = hasErrors) BOOL errors;
@property (readwrite,assign,nonatomic,getter = hasWarnings) BOOL warnings;
@property (readonly,nonatomic) NSImage *issueIcon;

+ (id)fileWithFileURL:(NSURL *)fileURL;
- (id)initWithFileURL:(NSURL *)fileURL;
@end
