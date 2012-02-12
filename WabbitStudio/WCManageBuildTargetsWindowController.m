//
//  WCManageBuildTargetsWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCManageBuildTargetsWindowController.h"
#import "WCProjectDocument.h"
#import "WCBuildTarget.h"

@implementation WCManageBuildTargetsWindowController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_projectDocument release];
	[super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
}

- (NSString *)windowNibName {
	return @"WCManageBuildTargetsWindow";
}

+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = [projectDocument retain];
	
	return self;
}

- (void)showManageBuildTargetsWindow; {
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}

- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
}
- (IBAction)edit:(id)sender; {
	
}

- (IBAction)newBuildTarget:(id)sender; {
	
}
- (IBAction)newBuildTargetFromTemplate:(id)sender; {
	
}

@synthesize projectDocument=_projectDocument;

- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context {
	[self autorelease];
	[sheet orderOut:nil];
	if (code == NSCancelButton)
		return;
	
	
}

@end
