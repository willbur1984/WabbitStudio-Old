//
//  WCNewProjectWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCNewProjectWindowController.h"
#import "RSDefines.h"
#import "WCDocumentController.h"
#import "WCGroup.h"
#import "WCFileContainer.h"
#import "RSDefines.h"
#import "NSURL+RSExtensions.h"
#import "WCProjectDocument.h"

@implementation WCNewProjectWindowController

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCNewProjectWindow";
}

+ (WCNewProjectWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (id)createProjectWithContentsOfDirectory:(NSURL *)directoryURL error:(NSError **)outError; {
	CFStringRef projectExtension = UTTypeCopyPreferredTagWithClass((CFStringRef)WCProjectFileUTI, kUTTagClassFilenameExtension);
	NSURL *projectURL = [directoryURL URLByAppendingPathComponent:[[directoryURL lastPathComponent] stringByAppendingPathExtension:(NSString *)projectExtension] isDirectory:NO];
	CFRelease(projectExtension);
	
	WCFileContainer *projectNode = [WCFileContainer fileContainerWithFile:[WCFile fileWithFileURL:projectURL]];
	
	NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLIsPackageKey,NSURLParentDirectoryURLKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
		
		return NO;
	}];
	
	NSMutableDictionary *directoryPathsToDirectoryNodes = [NSMutableDictionary dictionaryWithCapacity:0];
	for (NSURL *fileURL in directoryEnumerator) {
		if ([fileURL isDirectory]) {
			WCFileContainer *directoryNode = [WCFileContainer fileContainerWithFile:[WCGroup fileWithFileURL:fileURL]];
			
			[directoryPathsToDirectoryNodes setObject:directoryNode forKey:[fileURL path]];
			
			WCFileContainer *parentDirectoryNode = [directoryPathsToDirectoryNodes objectForKey:[[fileURL parentDirectoryURL] path]];
			
			if (parentDirectoryNode)
				[[parentDirectoryNode mutableChildNodes] addObject:directoryNode];
			else
				[[projectNode mutableChildNodes] addObject:directoryNode];
		}
		else if ([fileURL isPackage])
			continue;
		else {
			WCFileContainer *childNode = [WCFileContainer fileContainerWithFile:[WCFile fileWithFileURL:fileURL]];
			WCFileContainer *parentDirectoryNode = [directoryPathsToDirectoryNodes objectForKey:[[fileURL parentDirectoryURL] path]];
			
			if (parentDirectoryNode)
				[[parentDirectoryNode mutableChildNodes] addObject:childNode];
			else
				[[projectNode mutableChildNodes] addObject:childNode];
		}
	}
	
	NSFileWrapper *projectWrapper = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil] autorelease];
	NSData *projectData = [NSPropertyListSerialization dataWithPropertyList:[projectNode plistRepresentation] format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
	if (!projectData)
		return nil;
	
	[projectWrapper addRegularFileWithContents:projectData preferredFilename:WCProjectDataFileName];
	
	if (![projectWrapper writeToURL:projectURL options:NSFileWrapperWritingAtomic originalContentsURL:nil error:outError])
		return nil;
	
	return [[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:projectURL display:YES error:outError];
}

- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
	[[self window] orderOut:nil];
}
- (IBAction)createFromFolder:(id)sender; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setMessage:NSLocalizedString(@"Choose the folder you want to create your project from.", @"Choose the folder you want to create your project from.")];
	[openPanel setPrompt:LOCALIZED_STRING_CREATE];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		if ([self createProjectWithContentsOfDirectory:[[openPanel URLs] lastObject] error:NULL])
			[self cancel:nil];
	}];
}
- (IBAction)previous:(id)sender; {
	
}
- (IBAction)next:(id)sender; {
	
}
@end
