//
//  RSTransferFile.m
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTransferFile.h"

@implementation RSTransferFile
- (void)dealloc {
	if (_TIFile)
		FreeTiFile(_TIFile);
	[_URL release];
	[super dealloc];
}

+ (id)transferFileWithURL:(NSURL *)url; {
	return [[[[self class] alloc] initWithURL:url] autorelease];
}
- (id)initWithURL:(NSURL *)url; {
	if (!(self = [super init]))
		return nil;
	
	_URL = [url copy];
	
	TIFILE_t *tiFile = newimportvar([[url path] fileSystemRepresentation], FALSE);
	
	if (!tiFile) {
		[self release];
		return nil;
	}
	
	_TIFile = tiFile;
	
	size_t size = 0;
	
	switch (tiFile->type) {
		case RSTransferFileTypeFlash:
			for (uint16_t page=0; page<256; page++)
				size += tiFile->flash->pagesize[page];
			break;
		case RSTransferFileTypeGroup:
		case RSTransferFileTypeVar:
			size = tiFile->var->length;
			break;
		default:
			break;
	}
	
	_size = size;
	
	return self;
}

@dynamic type;
- (RSTransferFileType)type {
	return [self TIFile]->type;
}
@synthesize URL=_URL;
@synthesize TIFile=_TIFile;
@synthesize size=_size;
@synthesize currentProgress=_currentProgress;

@end
