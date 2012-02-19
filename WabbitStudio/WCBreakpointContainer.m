//
//  WCBreakpointContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointContainer.h"
#import "WCSourceSymbol.h"
#import "WCFileBreakpoint.h"
#import "WCBreakpointFileContainer.h"
#import "WCProjectDocument.h"
#import "WCSourceScanner.h"
#import "WCSourceFileDocument.h"
#import "NSArray+WCExtensions.h"
#import "WCSourceTextStorage.h"
#import "NSString+RSExtensions.h"

@implementation WCBreakpointContainer
- (void)dealloc {
	[_symbol release];
	[_name release];
	[super dealloc];
}

- (BOOL)isLeafNode {
	return YES;
}

+ (id)breakpointContainerWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint; {
	return [[[[self class] alloc] initWithFileBreakpoint:fileBreakpoint] autorelease];
}
- (id)initWithFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint; {
	if (!(self = [super initWithRepresentedObject:fileBreakpoint]))
		return nil;
	
	return self;
}

@dynamic symbol;
- (WCSourceSymbol *)symbol {
	if (!_symbol) {
		WCFileBreakpoint *fileBreakpoint = [self representedObject];
		WCSourceFileDocument *sfDocument = [[[fileBreakpoint projectDocument] filesToSourceFileDocuments] objectForKey:[fileBreakpoint file]];
		NSArray *symbols = [[sfDocument sourceScanner] symbols];
		
		_symbol = [[symbols sourceSymbolForRange:[fileBreakpoint range]] retain];
	}
	return _symbol;
}
@dynamic name;
- (NSString *)name {
	if (![_name length]) {
		WCFileBreakpoint *fileBreakpoint = [self representedObject];
		WCSourceFileDocument *sfDocument = [[[fileBreakpoint projectDocument] filesToSourceFileDocuments] objectForKey:[fileBreakpoint file]];
		NSString *string = [[sfDocument textStorage] string];
		
		_name = [[NSString stringWithFormat:NSLocalizedString(@"%@ - line %lu", @"breakpoint container name format string"),[[self symbol] name],[string lineNumberForRange:[fileBreakpoint range]]+1] copy];
	}
	return _name;
}

@end
