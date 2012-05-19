//
//  WCBuildController.m
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
#import "WCBuildDefine.h"
#import "WCProjectViewController.h"
#import "WCDebugController.h"
#import "RSBezelWidgetManager.h"

NSString *const WCBuildControllerDidFinishBuildingNotification = @"WCBuildControllerDidFinishBuildingNotification";

NSString *const WCBuildControllerDidChangeBuildIssueVisibleNotification = @"WCBuildControllerDidChangeBuildIssueVisibleNotification";
NSString *const WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey = @"WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey";

NSString *const WCBuildControllerDidChangeAllBuildIssuesVisibleNotification = @"WCBuildControllerDidChangeAllBuildIssuesVisibleNotification";

@interface WCBuildController ()
@property (readwrite,assign,nonatomic,getter = isBuilding) BOOL building;
@property (readonly,nonatomic) NSMutableString *output;
@property (readwrite,retain,nonatomic) NSTask *task;
@property (readwrite,retain,nonatomic) NSMapTable *filesToBuildIssuesSortedByLocation;
@property (readwrite,copy,nonatomic) NSArray *filesWithBuildIssuesSortedByName;
@property (readwrite,copy,nonatomic) NSSet *buildIssues;
@property (readwrite,assign,nonatomic,getter = isChangingVisibilityOfAllBuildIssues) BOOL changingVisibilityOfAllBuildIssues;
@property (readwrite,assign,nonatomic) NSUInteger totalErrors;
@property (readwrite,assign,nonatomic) NSUInteger totalWarnings;
@property (readwrite,copy,nonatomic) NSURL *lastOutputFileURL;

- (void)_processOutput;
@end

@implementation WCBuildController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_lastOutputFileURL release];
	[_filesToBuildIssuesSortedByLocation release];
	[_filesWithBuildIssuesSortedByName release];
	[_buildIssues release];
	[_task release];
	[_output release];
	_projectDocument = nil;
	[super dealloc];
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self) {
		if ([keyPath isEqualToString:@"visible"]) {
			if ([self isChangingVisibilityOfAllBuildIssues]) {
				NSNotification *note = [NSNotification notificationWithName:WCBuildControllerDidChangeAllBuildIssuesVisibleNotification object:self userInfo:nil];
				
				[[NSNotificationQueue defaultQueue] enqueueNotification:note postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName|NSNotificationCoalescingOnSender forModes:[NSArray arrayWithObjects:NSRunLoopCommonModes, nil]];
			}
			else {
				[[NSNotificationCenter defaultCenter] postNotificationName:WCBuildControllerDidChangeBuildIssueVisibleNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:object,WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey, nil]];
			}
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
#pragma mark *** Public Methods ***
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	_output = [[NSMutableString alloc] initWithCapacity:0];
	_buildFlags.issuesEnabled = YES;
	
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
	
	if ([self runAfterBuilding]) {
		if (![activeBuildTarget generateCodeListing]) {
			NSString *message = NSLocalizedString(@"No Code Listing", @"No Code Listing");
			NSString *informative = [NSString stringWithFormat:NSLocalizedString(@"The active build target \"%@\" is not set to generate a code listing, which is required for debugging. Do you want to enable code listing generation now?", @"build and run alert informative format string"),[activeBuildTarget name]];
			NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"Generate Code Listing", @"Generate Code Listing") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
			
			[alert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
				[[alert window] orderOut:nil];
				if (returnCode == NSAlertAlternateReturn)
					return;
				
				[activeBuildTarget setGenerateCodeListing:YES];
				[self runAfterBuilding];
			}];
			return;
		}
		else if (![[[self projectDocument] debugController] romOrSavestateForRunning]) {
			[[[self projectDocument] debugController] setBuildAfterRomOrSavestateSheetFinishes:YES];
			[[[self projectDocument] debugController] changeRomOrSavestateForRunning];
			return;
		}
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
	
	NSURL *outputDirectoryURL = nil;
	WCProjectBuildProductsLocation buildProductsLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:WCProjectBuildProductsLocationKey] unsignedIntValue];
	
	switch (buildProductsLocation) {
		case WCProjectBuildProductsLocationProjectFolder: {
			NSURL *projectDirectoryURL = [[[self projectDocument] fileURL] parentDirectoryURL];
			NSString *buildProductsDirectoryName = NSLocalizedString(@"Build Products", @"Build Products");
			NSString *buildTargetName = [activeBuildTarget name];
			
			outputDirectoryURL = [[projectDirectoryURL URLByAppendingPathComponent:buildProductsDirectoryName isDirectory:YES] URLByAppendingPathComponent:buildTargetName isDirectory:YES];
		}
			break;
		case WCProjectBuildProductsLocationCustom: {
			NSURL *customDirectoryURL = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:WCProjectBuildProductsLocationCustomKey] isDirectory:YES];
			NSString *projectName = [[[self projectDocument] displayName] stringByDeletingPathExtension];
			NSString *buildTargetName = [activeBuildTarget name];
			
			outputDirectoryURL = [[customDirectoryURL URLByAppendingPathComponent:projectName isDirectory:YES] URLByAppendingPathComponent:buildTargetName isDirectory:YES];
		}
			break;
		default:
			break;
	}
	
#ifdef DEBUG
    NSAssert(outputDirectoryURL, @"outputDirectoryURL cannot be nil!");
#endif
	
	if (![outputDirectoryURL checkResourceIsReachableAndReturnError:NULL]) {
		NSError *outError;
		if (![[NSFileManager defaultManager] createDirectoryAtURL:outputDirectoryURL withIntermediateDirectories:YES attributes:nil error:&outError]) {
			if (outError) {
				NSAlert *alert = [NSAlert alertWithError:outError];
				
				[alert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
					[[alert window] orderOut:nil];
				}];
			}
			return;
		}
	}
	
	// TODO: how to wait until the saves are finished before continuing with the build?
	NSArray *unsavedFiles = [[[self projectDocument] unsavedFiles] allObjects];
	if ([unsavedFiles count]) {
		WCProjectAutoSave autoSave = [[[NSUserDefaults standardUserDefaults] objectForKey:WCProjectAutoSaveKey] unsignedIntValue];
		
		switch (autoSave) {
			case WCProjectAutoSaveAlways:
				for (WCFile *file in unsavedFiles) {
					WCSourceFileDocument *sfDocument = [[[self projectDocument] filesToSourceFileDocuments] objectForKey:file];
					
					[sfDocument saveDocument:nil];
				}
				break;
			case WCProjectAutoSavePrompt:
				break;
			case WCProjectAutoSaveNever:
			default:
				break;
		}
	}
	
	NSString *outputDirectoryPath = [outputDirectoryURL path];
	NSString *inputFilePath = [inputFile filePath];
	NSString *outputFileName = [[[self projectDocument] displayName] stringByDeletingPathExtension];
	NSString *outputFileExtension = [activeBuildTarget outputFileExtension];
	NSString *outputFilePath = [outputDirectoryPath stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:outputFileExtension]];
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
	
	if ([activeBuildTarget generateCodeListing])
		[arguments addObject:@"-T"];
	if ([activeBuildTarget generateLabelFile])
		[arguments addObject:@"-L"];
	if ([activeBuildTarget symbolsAreCaseSensitive])
		[arguments addObject:@"-A"];
	
	if ([[activeBuildTarget includes] count]) {
		for (WCBuildInclude *include in [activeBuildTarget includes])
			[arguments addObject:[NSString stringWithFormat:@"-I%@",[include path]]];
	}
	
	[arguments addObject:inputFilePath];
	
	if ([[activeBuildTarget defines] count]) {
		for (WCBuildDefine *define in [activeBuildTarget defines]) {
			NSMutableString *temp = [NSMutableString stringWithFormat:@"-D%@",[define name]];
			
			if ([[define value] length])
				[temp appendFormat:@"=%@",[define value]];
			
			[arguments addObject:temp];
		}
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
	
	[self setLastOutputFileURL:[NSURL fileURLWithPath:outputFilePath isDirectory:NO]];
	
	@try {
		[[self task] launch];
	}
	@catch (NSException *exception) {
		NSLog(@"exception while running build task %@",exception);
	}
}
- (void)buildAndRun; {
	[self setRunAfterBuilding:YES];
	[self build];
}

- (void)performCleanup; {
	for (WCBuildIssue *issue in [self buildIssues])
		[issue removeObserver:self forKeyPath:@"visible" context:self];
}
#pragma mark Properties
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
@synthesize buildIssues=_buildIssues;
@dynamic issuesEnabled;
- (BOOL)issuesEnabled {
	return _buildFlags.issuesEnabled;
}
- (void)setIssuesEnabled:(BOOL)issuesEnabled {
	_buildFlags.issuesEnabled = issuesEnabled;
	
	[self setChangingVisibilityOfAllBuildIssues:YES];
	
	if (issuesEnabled) {
		for (WCBuildIssue *buildIssue in [self buildIssues])
			[buildIssue setVisible:YES];
	}
	else {
		for (WCBuildIssue *buildIssue in [self buildIssues])
			[buildIssue setVisible:NO];
	}
	
	[self setChangingVisibilityOfAllBuildIssues:NO];
}
@dynamic changingVisibilityOfAllBuildIssues;
- (BOOL)isChangingVisibilityOfAllBuildIssues {
	return _buildFlags.changingVisibilityOfAllBuildIssues;
}
- (void)setChangingVisibilityOfAllBuildIssues:(BOOL)changingVisibilityOfAllBuildIssues {
	_buildFlags.changingVisibilityOfAllBuildIssues = changingVisibilityOfAllBuildIssues;
}
@synthesize totalErrors=_totalErrors;
@synthesize totalWarnings=_totalWarnings;
@synthesize lastOutputFileURL=_lastOutputFileURL;
@dynamic outputCopy;
- (NSString *)outputCopy {
    return [[self.output copy] autorelease];
}
#pragma mark *** Private Methods ***
- (void)_processOutput; {	
    RSLog(@"process output");
    
	NSString *output = [[[self output] copy] autorelease];
	NSDictionary *filePathsToFiles = [[self projectDocument] filePathsToFiles];
	NSMapTable *filesToSourceFileDocuments = [[self projectDocument] filesToSourceFileDocuments];
	BOOL issuesEnabled = [self issuesEnabled];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSRegularExpression *messageRegex = [[[NSRegularExpression alloc] initWithPattern:@"\\s*([ .A-Za-z0-9_/]+):([0-9]+):\\s*(error|warning)\\s+([A-Za-z0-9]+):\\s*(.*)" options:0 error:NULL] autorelease];
		NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
		NSMapTable *filesToBuildIssues = [NSMapTable mapTableWithWeakToStrongObjects];
		NSMutableSet *allBuildIssues = [NSMutableSet setWithCapacity:0];
		__block NSUInteger totalErrors = 0;
		__block NSUInteger totalWarnings = 0;
		
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
			
			if ([issueType isEqualToString:@"error"]) {
				buildIssue = [WCBuildIssue buildIssueOfType:WCBuildIssueTypeError range:range message:message code:code];
				totalErrors++;
			}
			else {
				buildIssue = [WCBuildIssue buildIssueOfType:WCBuildIssueTypeWarning range:range message:message code:code];
				totalWarnings++;
			}
			
			if (issuesEnabled)
				[buildIssue setVisible:YES];
			else
				[buildIssue setVisible:NO];
			
			NSMutableArray *buildIssues = [filesToBuildIssues objectForKey:file];
			
			if (!buildIssues) {
				buildIssues = [NSMutableArray arrayWithCapacity:0];
				
				[filesToBuildIssues setObject:buildIssues forKey:file];
				[files addObject:file];
			}
			
			[buildIssues addObject:buildIssue];
			[allBuildIssues addObject:buildIssue];
		}];
		
		[files sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
		
		for (NSMutableArray *buildIssues in [filesToBuildIssues objectEnumerator]) {
			[buildIssues sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
				if ([obj1 rangeValue].location < [obj2 rangeValue].location)
					return NSOrderedAscending;
				else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
					return NSOrderedDescending;
				return NSOrderedSame;
			}],[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
		}
			
		dispatch_async(dispatch_get_main_queue(), ^{
			for (WCFile *file in [self filesWithBuildIssuesSortedByName]) {
				[file setErrors:NO];
				[file setWarnings:NO];
			}
			
			for (WCBuildIssue *issue in [self buildIssues])
				[issue removeObserver:self forKeyPath:@"visible" context:self];
			
			[self setBuildIssues:allBuildIssues];
			[self setFilesToBuildIssuesSortedByLocation:filesToBuildIssues];
			[self setFilesWithBuildIssuesSortedByName:files];
			
			for (WCBuildIssue *issue in [self buildIssues])
				[issue addObserver:self forKeyPath:@"visible" options:0 context:self];
			
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
			
			[self setTotalErrors:totalErrors];
			[self setTotalWarnings:totalWarnings];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:WCBuildControllerDidFinishBuildingNotification object:self];
			
			if (!totalErrors && !totalWarnings)
				[[RSBezelWidgetManager sharedWindowController] showString:NSLocalizedString(@"Build Succeeded", @"Build Succeeded") centeredInView:[[[self projectDocument] windowForSheet] contentView]];
			else if (!totalErrors)
				[[RSBezelWidgetManager sharedWindowController] showString:[NSString stringWithFormat:NSLocalizedString(@"Build Succeeded (%lu warnings)", @"Build Succeeded (%lu warnings)"),totalWarnings] centeredInView:[[[self projectDocument] windowForSheet] contentView] withCloseDelay:1.25];
			else
				[[RSBezelWidgetManager sharedWindowController] showString:[NSString stringWithFormat:NSLocalizedString(@"Build Failed (%lu errors, %lu warnings)", @"Build Failed (%lu errors, %lu warnings)"),totalErrors,totalWarnings] centeredInView:[[[self projectDocument] windowForSheet] contentView] withCloseDelay:1.25];
            
            [self setBuilding:NO];
		});
		
		[pool release];
	});
}
#pragma mark Notifications

- (void)_readDataFromTask:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
    
	NSData *data = [[note userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	if ([data length]) {
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		
		[[self output] appendString:string];
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_readDataFromTask:) name:NSFileHandleReadCompletionNotification object:[[[self task] standardOutput] fileHandleForReading]];
        
		[[note object] readInBackgroundAndNotify];
	}
	else {
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
