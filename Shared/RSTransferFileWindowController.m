//
//  RSTransferFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTransferFileWindowController.h"
#import "RSCalculator.h"
#import "RSTransferFile.h"
#import "NSURL+RSExtensions.h"
#import "RSDefines.h"

@interface RSTransferFileWindowController ()
@property (readwrite,copy,nonatomic) NSString *statusString;
@property (readwrite,assign) RSTransferFile *currentTransferFile;
@property (readwrite,assign,nonatomic) CGFloat currentProgress;
@property (readwrite,assign,nonatomic) CGFloat totalSize;

- (void)_transferRomsAndSavestates;
- (void)_transferOtherFiles;
@end

@implementation RSTransferFileWindowController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_delegate = nil;
	_currentTransferFile = nil;
	[_romsAndSavestates release];
	[_otherFiles release];
	[_calculator release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"RSTransferFileWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self progressIndicator] startAnimation:nil];
	[[self progressIndicator] setIndeterminate:NO];
	
	CGFloat totalSize = 0;
	for (RSTransferFile *transferFile in _otherFiles)
		totalSize += [transferFile size];
	
	[self setTotalSize:totalSize];
	
	[[self calculator] setActive:NO];
	[[self calculator] setRunning:NO];
	
	NSTimer *progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_progressTimerCallback:) userInfo:nil repeats:YES];
	LPCALC calculator = [[self calculator] calculator];
	
	never_forceload_apps = TRUE;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		for (RSTransferFile *transferFile in _otherFiles) {
			[self setCurrentTransferFile:transferFile];
			
			TIFILE_t *tiFile = [transferFile TIFile];
			
			calculator->cpu.pio.link->vlink_send = 0;
			
			LINK_ERR linkError = link_send_var(&(calculator->cpu), tiFile, SEND_CUR);
			
#ifdef DEBUG
			if (linkError)
				NSLog(@"link error %d",linkError);
#endif
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[progressTimer invalidate];
			[[NSApplication sharedApplication] endSheet:[self window]];
		});
		
		[pool release];
	});
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_calculator = [calculator retain];
	_romsAndSavestates = [[NSMutableArray alloc] initWithCapacity:0];
	_otherFiles = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

- (void)showTransferFileWindowForTransferFileURLs:(NSArray *)transferFileURLs; {	
	for (NSURL *transferFileURL in transferFileURLs) {
		RSTransferFile *transferFile = [RSTransferFile transferFileWithURL:transferFileURL];
		
		switch ([transferFile type]) {
			case RSTransferFileTypeRom:
			case RSTransferFileTypeSavestate:
				[_romsAndSavestates addObject:transferFile];
				break;
			case RSTransferFileTypeVar:
			case RSTransferFileTypeFlash:
			case RSTransferFileTypeGroup:
				[_otherFiles addObject:transferFile];
				break;
			default:
				break;
		}
	}
	
	[self _transferRomsAndSavestates];
	[self _transferOtherFiles];
}

+ (NSArray *)filterTransferFileURLs:(NSArray *)transferFileURLs; {
	NSMutableArray *validTransferFileURLs = [NSMutableArray arrayWithCapacity:[transferFileURLs count]];
	
	for (NSURL *transferFileURL in transferFileURLs) {
		NSString *transferFileUTI = [transferFileURL fileUTI];
		
		if ([transferFileUTI isEqualToString:RSCalculatorRomUTI] ||
			[transferFileUTI isEqualToString:RSCalculatorSavestateUTI] ||
			[transferFileUTI isEqualToString:RSCalculatorProgramUTI] ||
			[transferFileUTI isEqualToString:RSCalculatorApplicationUTI] ||
			[transferFileUTI isEqualToString:RSCalculatorGroupFileUTI]) {
			
			[validTransferFileURLs addObject:transferFileURL];
		}
	}
	
	return [[validTransferFileURLs copy] autorelease];
}

@synthesize progressIndicator=_progressIndicator;

@synthesize delegate=_delegate;
@synthesize calculator=_calculator;
@synthesize statusString=_statusString;
@synthesize currentProgress=_currentProgress;
@synthesize currentTransferFile=_currentTransferFile;
@synthesize totalSize=_totalSize;

- (void)_transferRomsAndSavestates; {
	if (![_romsAndSavestates count])
		return;
	
	NSError *outError;
	if (![[self calculator] loadRomOrSavestateAtURL:[[_romsAndSavestates objectAtIndex:0] URL] error:&outError])
		[[NSApplication sharedApplication] presentError:outError];
	
	[_romsAndSavestates removeObjectAtIndex:0];
	
	for (RSTransferFile *transferFile in _romsAndSavestates) {
		[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[transferFile URL] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
			if (error)
				[[NSApplication sharedApplication] presentError:error];
		}];
	}
}

- (void)_transferOtherFiles; {
	if (![_otherFiles count])
		return;
	
	// make Clang shut up
	[self performSelector:@selector(retain)];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self delegate] windowForTransferFileWindowControllerSheet:self] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
}

- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context; {
	// make Clang shut up
	[self performSelector:@selector(autorelease)];
	[sheet orderOut:nil];
	
	[[self calculator] setActive:YES];
	[[self calculator] setRunning:YES];
}

- (void)_progressTimerCallback:(NSTimer *)timer {
	[self setStatusString:[NSString stringWithFormat:NSLocalizedString(@"Transferring \"%@\" (%lu of %lu)\u2026", @"transfer sheet status string format"),[[[[self currentTransferFile] URL] path] lastPathComponent],[_otherFiles indexOfObject:[self currentTransferFile]]+1,[_otherFiles count]]];
	
	CGFloat currentFileProgress = ABS([[self calculator] calculator]->cpu.pio.link->vlink_send - [[self currentTransferFile] currentProgress]);
	
	if (currentFileProgress >= [[self currentTransferFile] size]) {
		[[self currentTransferFile] setCurrentProgress:0];
		return;
	}
	
	[self setCurrentProgress:[self currentProgress] + currentFileProgress];
	
	if ([self currentProgress] >= [self totalSize]) {
		[[self progressIndicator] setIndeterminate:YES];
		[[self progressIndicator] startAnimation:nil];
		[self setStatusString:NSLocalizedString(@"Almost finished\u2026", @"Almost finished with ellipsis")];
		return;
	}
	
	[[self currentTransferFile] setCurrentProgress:[[self calculator] calculator]->cpu.pio.link->vlink_send];
}

@end
