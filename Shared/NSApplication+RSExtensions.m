//
//  NSApplication+RSExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
