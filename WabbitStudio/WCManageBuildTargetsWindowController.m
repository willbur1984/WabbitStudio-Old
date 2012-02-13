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
#import "RSTableView.h"
#import "NSArray+WCExtensions.h"
#import "WCEditBuildTargetWindowController.h"
#import "RSDefines.h"

@implementation WCManageBuildTargetsWindowController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
}

- (NSString *)windowNibName {
	return @"WCManageBuildTargetsWindow";
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return ([[fieldEditor string] length]);
}

- (void)handleSpacePressedForTableView:(RSTableView *)tableView {
	WCBuildTarget *selectedBuildTarget = [[[self arrayController] selectedObjects] firstObject];
	
	[[self projectDocument] setActiveBuildTarget:selectedBuildTarget];
}

+ (id)manageBuildTargetsWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

- (void)showManageBuildTargetsWindow; {
	[self retain];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}

- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
}
- (IBAction)editBuildTarget:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)newBuildTarget:(id)sender; {
	WCBuildTarget *newBuildTarget = [WCBuildTarget buildTargetWithName:NSLocalizedString(@"New Target", @"New Target") outputType:WCBuildTargetOutputTypeBinary projectDocument:[self projectDocument]];
	NSUInteger selectionIndex = [[[self arrayController] selectionIndexes] firstIndex];
	
	if (selectionIndex == NSNotFound)
		selectionIndex = 0;
	
	[[self arrayController] insertObject:newBuildTarget atArrangedObjectIndex:selectionIndex];
	
	[[self tableView] editColumn:1 row:selectionIndex withEvent:nil select:YES];
}
- (IBAction)newBuildTargetFromTemplate:(id)sender; {
	
}

@synthesize tableView=_tableView;
@synthesize arrayController=_arrayController;

@synthesize projectDocument=_projectDocument;

- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context {
	[self autorelease];
	[sheet orderOut:nil];
	
	if (code == NSCancelButton)
		return;
	
	WCBuildTarget *buildTarget = [[[self arrayController] selectedObjects] firstObject];
	WCEditBuildTargetWindowController *windowController = [WCEditBuildTargetWindowController editBuildTargetWindowControllerWithBuildTarget:buildTarget];
	
	[windowController showEditBuildTargetWindow];
}

@end
