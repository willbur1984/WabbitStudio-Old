//
//  WCEditBuildTargetWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCEditBuildTargetWindowController.h"
#import "WCBuildTarget.h"
#import "WCProjectDocument.h"

@implementation WCEditBuildTargetWindowController
- (void)dealloc {
	[_buildTarget release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCEditBuildTargetWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
}

+ (id)editBuildTargetWindowControllerWithBuildTarget:(WCBuildTarget *)buildTarget; {
	return [[[[self class] alloc] initWithBuildTarget:buildTarget] autorelease];
}
- (id)initWithBuildTarget:(WCBuildTarget *)buildTarget; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_buildTarget = [buildTarget retain];
	
	return self;
}

- (void)showEditBuildTargetWindow; {
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[[self buildTarget] projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}

- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
}
- (IBAction)manageBuildTargets:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
}
- (IBAction)duplicateBuildTarget:(id)sender; {
	
}

- (IBAction)newBuildDefine:(id)sender; {
	
}
- (IBAction)deleteBuildDefine:(id)sender; {
	
}

@synthesize buildTarget=_buildTarget;

- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context {
	[self autorelease];
	[sheet orderOut:nil];
	if (code == NSCancelButton)
		return;
	
	[[[self buildTarget] projectDocument] manageBuildTargets:nil];
}

@end
