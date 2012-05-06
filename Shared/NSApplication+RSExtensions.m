//
//  NSApplication+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSApplication+RSExtensions.h"

@implementation NSApplication (RSExtensions)
- (void)beginSheet: (NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock: (void (^)(NSInteger returnCode))block {
	[self beginSheet: sheet
	  modalForWindow: docWindow
	   modalDelegate: self
	  didEndSelector: @selector(my_blockSheetDidEnd:returnCode:contextInfo:)
		 contextInfo: [block copy]];
}

- (void)my_blockSheetDidEnd: (NSWindow *)sheet returnCode: (NSInteger)returnCode contextInfo: (void *)contextInfo {
	void (^block)(NSInteger returnCode) = contextInfo;
	block(returnCode);
	[block release];
}
@end
