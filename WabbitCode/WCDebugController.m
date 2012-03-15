//
//  WCDebugController.m
//  WabbitStudio
//
//  Created by William Towe on 2/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCDebugController.h"
#import "RSCalculator.h"
#import "RSTransferFileWindowController.h"
#import "WCFile.h"
#import "WCProjectDocument.h"
#import "WCBuildController.h"
#import "RSFileReference.h"
#import "RSDefines.h"

NSString *const WCDebugControllerDebugSessionDidBeginNotification = @"WCDebugControllerDebugSessionDidBeginNotification";
NSString *const WCDebugControllerDebugSessionDidEndNotification = @"WCDebugControllerDebugSessionDidEndNotification";
NSString *const WCDebugControllerCurrentFileDidChangeNotification = @"WCDebugControllerCurrentFileDidChangeNotification";
NSString *const WCDebugControllerCurrentLineNumberDidChangeNotification = @"WCDebugControllerCurrentLineNumberDidChangeNotification";

@interface WCDebugController ()
@property (readwrite,copy,nonatomic) NSString *codeListing;
@property (readwrite,copy,nonatomic) NSString *labelFile;
@property (readwrite,retain,nonatomic) WCFile *currentFile;
@property (readwrite,assign,nonatomic) NSUInteger currentLineNumber;
@property (readwrite,retain,nonatomic) RSFileReference *romOrSavestateForRunning;

@end

@implementation WCDebugController
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_projectDocument = nil;
	[_romOrSavestateForRunning release];
	[_calculator release];
	[_codeListing release];
	[_labelFile release];
	[_currentFile release];
	[super dealloc];
}

- (NSWindow *)windowForTransferFileWindowControllerSheet:(RSTransferFileWindowController *)transferFileWindowController {
	return [[self projectDocument] windowForSheet];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	_currentLineNumber = NSUIntegerMax;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:[_projectDocument buildController]];
	
	return self;
}

+ (NSGradient *)debugFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:0.05] endingColor:[NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:0.3]];
	});
	return retval;
}
+ (NSColor *)debugFillColor; {
	return [NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:1.0];
}

- (void)changeRomOrSavestateForRunning; {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:RSCalculatorRomUTI,RSCalculatorSavestateUTI, nil]];
	[openPanel setPrompt:LOCALIZED_STRING_CHOOSE];
	
	[openPanel beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		[self setRomOrSavestateForRunning:[RSFileReference fileReferenceWithFileURL:[[openPanel URLs] lastObject]]];
	}];
}

@synthesize projectDocument=_projectDocument;
@dynamic calculator;
- (RSCalculator *)calculator {
	if (!_calculator) {
		_calculator = [[RSCalculator alloc] initWithRomOrSavestateURL:nil error:NULL];
		[_calculator setDelegate:self];
	}
	return _calculator;
}
@synthesize codeListing=_codeListing;
@synthesize labelFile=_labelFile;
@synthesize currentFile=_currentFile;
@synthesize currentLineNumber=_currentLineNumber;
@dynamic debugging;
- (BOOL)isDebugging {
	return _debugFlags.debugging;
}
- (void)setDebugging:(BOOL)debugging {
	_debugFlags.debugging = debugging;
}
@synthesize romOrSavestateForRunning=_romOrSavestateForRunning;

- (void)_buildControllerDidFinishBuilding:(NSNotification *)note {
	WCBuildController *buildController = [note object];
	
	if ([buildController totalErrors] && [buildController runAfterBuilding]) {
		[self setCodeListing:nil];
		[self setLabelFile:nil];
		[self setCurrentFile:nil];
		[self setCurrentLineNumber:NSUIntegerMax];
	}
	else {
		NSError *outError;
		if (![[self calculator] loadRomOrSavestateAtURL:[[self romOrSavestateForRunning] fileURL] error:&outError]) {
			if (outError) {
				[[NSApplication sharedApplication] presentError:outError];
				return;
			}
		}
	}
}

@end
