//
//  WCBuildController.m
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildController.h"
#import "WCProjectDocument.h"
#import "WCBuildTarget.h"
#import "RSDefines.h"
#import "NSAlert-OAExtensions.h"
#import "WCFile.h"
#import "NSURL+RSExtensions.h"
#import "WCSourceFileDocument.h"
#import "WCSourceTextStorage.h"
#import "NSString+RSExtensions.h"
#import "WCBuildIssue.h"
#import "WCBuildInclude.h"

NSString *const WCBuildControllerDidFinishBuildingNotification = @"WCBuildControllerDidFinishBuildingNotification";

@interface WCBuildController ()
@property (readwrite,assign,nonatomic,getter = isBuilding) BOOL building;
@property (readwrite,assign,nonatomic) BOOL runAfterBuilding;
@property (readonly,nonatomic) NSMutableString *output;
@property (readwrite,retain,nonatomic) NSTask *task;
@property (readwrite,retain,nonatomic) NSMapTable *filesToBuildIssuesSortedByLocation;
@property (readwrite,copy,nonatomic) NSArray *filesWithBuildIssuesSortedByName;

- (void)_processOutput;
@end

@implementation WCBuildController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_filesToBuildIssuesSortedByLocation release];
	[_filesWithBuildIssuesSortedByName release];
	[_task release];
	[_output release];
	_projectDocument = nil;
	[super dealloc];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	_output = [[NSMutableString alloc] initWithCapacity:0];
	
	return self;
}

- (void)build; {
	if ([self isBuilding]) {
		NSBeep();
		return;
	}
	
	if (![[[self projectDocument] buildTargets] count]) {
		NSString *message = NSLocalizedString(@"No Build Targets", @"No Build Targets");
		NSString *informative = NSLocalizedString(@"Your project does not have any build targets. Would you like to edit your build targets now?", @"no build targets alert informative string");
		NSAlert *noBuildTargetsAlert = [NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"Edit Build Targets\u2026", @"Edit Build Targets with ellipsis") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
		
		[noBuildTargetsAlert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self projectDocument] manageBuildTargets:nil];
		}];
		return;
	}
	
	WCBuildTarget *activeBuildTarget = [[self projectDocument] activeBuildTarget];
	
	if (!activeBuildTarget) {
		NSString *message = NSLocalizedString(@"No Active Build Target", @"No Active Build Target");
		NSString *informative = NSLocalizedString(@"Your project does not have an active build target. Would you like to assign an active build target now?", @"no active build target alert informative string");
		NSAlert *noActiveBuildTargetAlert = [NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"Assign Active Build Target\u2026", @"Assign Active Build Target with ellipsis") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
		
		[noActiveBuildTargetAlert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self projectDocument] manageBuildTargets:nil];
		}];
		return;
	}
	
	WCFile *inputFile = [activeBuildTarget inputFile];
	
	if (!inputFile) {
		NSAlert *noInputFileAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"No Input File", @"No Input File") defaultButton:NSLocalizedString(@"Edit Active Build Target\u2026", @"Edit Active Build Target with ellipsis") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:NSLocalizedString(@"The active build target \"%@\" does not have an input file. Would you like to edit the active build target now?", @"no input file alert informative text format string"),[activeBuildTarget name]];
		
		[noInputFileAlert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self projectDocument] editActiveBuildTarget:nil];
		}];
		return;
	}
	
	NSURL *outputDirectoryURL = [[[self projectDocument] fileURL] parentDirectoryURL];
	NSString *outputDirectoryPath = [outputDirectoryURL path];
	NSString *inputFilePath = [inputFile filePath];
	NSString *outputFileName = [[[[self projectDocument] fileURL] lastPathComponent] stringByDeletingPathExtension];
	NSString *outputFileExtension = @"8xk";
	NSString *outputFilePath = [outputDirectoryPath stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:outputFileExtension]];
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
	
	if ([activeBuildTarget generateCodeListing])
		[arguments addObject:@"-T"];
	if ([activeBuildTarget generateLabelFile])
		[arguments addObject:@"-L"];
	if ([activeBuildTarget symbolsAreCaseSensitive])
		[arguments addObject:@"-A"];
	
	if ([[activeBuildTarget includes] count]) {
		// TODO: add processed include directories
		for (WCBuildInclude *include in [activeBuildTarget includes])
			[arguments addObject:[NSString stringWithFormat:@"-I%@",[include path]]];
	}
	
	[arguments addObject:inputFilePath];
	
	if ([[activeBuildTarget defines] count]) {
		// TODO: add processed defines
	}
	
	[arguments addObject:outputFilePath];
	
	[[self output] setString:@""];
	
	[self setTask:[[[NSTask alloc] init] autorelease]];
	
	[[self task] setLaunchPath:[[NSBundle mainBundle] pathForResource:@"spasm" ofType:@""]];
	[[self task] setCurrentDirectoryPath:[[[[self projectDocument] fileURL] parentDirectoryURL] path]];
	[[self task] setStandardOutput:[NSPipe pipe]];
	[[self task] setStandardError:[[self task] standardOutput]];
	[[self task] setArguments:arguments];
	
#ifdef DEBUG
    NSLog(@"%@",arguments);
#endif
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_readDataFromTask:) name:NSFileHandleReadCompletionNotification object:[[[self task] standardOutput] fileHandleForReading]];
	[[[[self task] standardOutput] fileHandleForReading] readInBackgroundAndNotify];
	
	[self setBuilding:YES];
	
	@try {
		[[self task] launch];
	}
	@catch (NSException *exception) {
		
	}
	@finally {
		[self setTask:nil];
		[self setBuilding:NO];
	}
}
- (void)buildAndRun; {
	[self setRunAfterBuilding:YES];
	[self build];
}

@synthesize projectDocument=_projectDocument;
@dynamic building;
- (BOOL)isBuilding {
	return _buildFlags.building;
}
- (void)setBuilding:(BOOL)building {
	_buildFlags.building = building;
}
@dynamic runAfterBuilding;
- (BOOL)runAfterBuilding {
	return _buildFlags.runAfterBuilding;
}
- (void)setRunAfterBuilding:(BOOL)runAfterBuilding {
	_buildFlags.runAfterBuilding = runAfterBuilding;
}
@synthesize output=_output;
@synthesize task=_task;
@synthesize filesWithBuildIssuesSortedByName=_filesWithBuildIssuesSortedByName;
@synthesize filesToBuildIssuesSortedByLocation=_filesToBuildIssuesSortedByLocation;

- (void)_processOutput; {	
	NSString *output = [[[self output] copy] autorelease];
	NSDictionary *filePathsToFiles = [[self projectDocument] filePathsToFiles];
	NSMapTable *filesToSourceFileDocuments = [[self projectDocument] filesToSourceFileDocuments];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSRegularExpression *messageRegex = [[[NSRegularExpression alloc] initWithPattern:@"\\s*([ .A-Za-z0-9_/]+):([0-9]+):\\s*(error|warning)\\s+([A-Za-z0-9]+):\\s*(.*)" options:0 error:NULL] autorelease];
		NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
		NSMapTable *filesToBuildIssues = [NSMapTable mapTableWithWeakToStrongObjects];
		
		[output enumerateSubstringsInRange:NSMakeRange(0, [output length]) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSTextCheckingResult *result = [messageRegex firstMatchInString:substring options:0 range:NSMakeRange(0, [substring length])];
			
			if (!result)
				return;
			
			NSString *filePath = [substring substringWithRange:[result rangeAtIndex:1]];
			WCFile *file = [filePathsToFiles objectForKey:filePath];
			
			if (!file)
				return;
			
			NSUInteger lineNumber = [[substring substringWithRange:[result rangeAtIndex:2]] integerValue] - 1;
			NSTextStorage *textStorage = [[filesToSourceFileDocuments objectForKey:file] textStorage];
			NSRange range = NSMakeRange([[textStorage string] rangeForLineNumber:lineNumber].location, 0);
			NSString *issueType = [[substring substringWithRange:[result rangeAtIndex:3]] lowercaseString];
			NSString *message = [substring substringWithRange:[result rangeAtIndex:5]];
			NSString *code = [substring substringWithRange:[result rangeAtIndex:4]];
			WCBuildIssue *buildIssue;
			
			if ([issueType isEqualToString:@"error"])
				buildIssue = [WCBuildIssue buildIssueOfType:WCBuildIssueTypeError range:range message:message code:code];
			else
				buildIssue = [WCBuildIssue buildIssueOfType:WCBuildIssueTypeWarning range:range message:message code:code];
			
			NSMutableArray *buildIssues = [filesToBuildIssues objectForKey:file];
			
			if (!buildIssues) {
				buildIssues = [NSMutableArray arrayWithCapacity:0];
				
				[filesToBuildIssues setObject:buildIssues forKey:file];
				[files addObject:file];
			}
			
			[buildIssues addObject:buildIssue];
		}];
		
		[files sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
		
		for (NSMutableArray *buildIssues in [filesToBuildIssues objectEnumerator])
			[buildIssues sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
				if ([obj1 rangeValue].location < [obj2 rangeValue].location)
					return NSOrderedAscending;
				else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
					return NSOrderedDescending;
				return NSOrderedSame;
			}],[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			for (WCFile *file in [self filesWithBuildIssuesSortedByName]) {
				[file setErrors:NO];
				[file setWarnings:NO];
			}
			
			[self setFilesToBuildIssuesSortedByLocation:filesToBuildIssues];
			[self setFilesWithBuildIssuesSortedByName:files];
			
			for (WCFile *file in [self filesWithBuildIssuesSortedByName]) {
				for (WCBuildIssue *issue in [[self filesToBuildIssuesSortedByLocation] objectForKey:file]) {
					if ([issue type] == WCBuildIssueTypeError) {
						[file setErrors:YES];
						break;
					}
					else if ([issue type] == WCBuildIssueTypeWarning)
						[file setWarnings:YES];
				}
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:WCBuildControllerDidFinishBuildingNotification object:self];
		});
		
		[pool release];
	});
}

- (void)_readDataFromTask:(NSNotification *)note {
	NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	if ([data length]) {
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		[[self output] appendString:string];
		
		[[note object] readInBackgroundAndNotify];
	}
	else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
		
		[[self task] terminate];
		
		while ((data = [[[[self task] standardOutput] fileHandleForReading] availableData]) && [data length]) {
			NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
			
			[[self output] appendString:string];
		}
		
		[self setTask:nil];
		
		[self _processOutput];
	}
}

@end
