//
//  RSTransferFile.h
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
