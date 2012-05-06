//
//  RSTransferFile.m
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
