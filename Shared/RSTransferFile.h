//
//  RSTransferFile.h
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/NSObject.h>
#include "var.h"

typedef enum _RSTransferFileType {
	RSTransferFileTypeRom = ROM_TYPE,
	RSTransferFileTypeFlash = FLASH_TYPE,
	RSTransferFileTypeVar = VAR_TYPE,
	RSTransferFileTypeSavestate = SAV_TYPE,
	RSTransferFileTypeBackup = BACKUP_TYPE,
	RSTransferFileTypeLabel = LABEL_TYPE,
	RSTransferFileTypeBreakpoint = BREAKPOINT_TYPE,
	RSTransferFileTypeGroup = GROUP_TYPE
	
} RSTransferFileType;

@interface RSTransferFile : NSObject {
	NSURL *_URL;
	TIFILE_t *_TIFile;
	size_t _size;
	CGFloat _currentProgress;
}
@property (readonly,nonatomic) RSTransferFileType type;
@property (readonly,nonatomic) NSURL *URL;
@property (readonly,nonatomic) TIFILE_t *TIFile;
@property (readonly,nonatomic) size_t size;
@property (readwrite,assign) CGFloat currentProgress;

+ (id)transferFileWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;

@end
