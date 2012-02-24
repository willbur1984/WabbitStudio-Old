//
//  WEHardwareViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WEHardwareViewController.h"
#import "RSLCDView.h"
#import "RSLCDViewManager.h"
#import "NSURL+RSExtensions.h"
#import "RSDefines.h"
#import "WECalculatorDocument.h"
#import "RSDontSelectPopUpButton.h"
#import "RSCalculator.h"

@interface WEHardwareViewController ()

@end

@implementation WEHardwareViewController

- (NSString *)nibName {
	return @"WEHardwareView";
}

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	return self;
}

- (void)loadView {
	[super loadView];
	
	RSLCDView *lcdView = [[[RSLCDView alloc] initWithFrame:[[self dummyLCDView] frame] calculator:nil] autorelease];
	
	[[[self dummyLCDView] superview] replaceSubview:[self dummyLCDView] with:lcdView];
	[self setLCDView:lcdView];
	
	[(NSPopUpButtonCell *)[[self previewSourcePopUpButton] cell] setAltersStateOfSelectedItem:YES];
	[self menuNeedsUpdate:[self previewSourceMenu]];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	if (newWindow && [[self LCDView] calculator])
		[[RSLCDViewManager sharedManager] addLCDView:[self LCDView]];
	else
		[[RSLCDViewManager sharedManager] removeLCDView:[self LCDView]];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
	[menu removeAllItems];
	
	NSArray *openDocuments = [[NSDocumentController sharedDocumentController] documents];
	
	if ([openDocuments count]) {
		for (NSDocument *document in openDocuments) {
			NSMenuItem *item = [menu addItemWithTitle:[document displayName] action:@selector(_previewSourceMenuItemClicked:) keyEquivalent:@""];
			
			[item setTarget:self];
			[item setImage:[[document fileURL] fileIcon]];
			[[item image] setSize:NSSmallSize];
			[item setRepresentedObject:[document fileURL]];
		}
	}
	else {
		NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"No Source", @"No Source") action:@selector(_previewSourceMenuItemClicked:) keyEquivalent:@""];
		
		[item setTarget:self];
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"Choose Source\u2026", @"Choose Source with ellipsis") action:@selector(_choosePreviewSource:) keyEquivalent:@""];
	
	[item setTarget:self];
	[item setTag:RSDontSelectTag];
}
- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id *)target action:(SEL *)action {
	return NO;
}

- (NSString *)identifier; {
	return @"org.wabbitemu.preferences.hardware";
}
- (NSString *)label; {
	return NSLocalizedString(@"Hardware", @"Hardware");
}
- (NSImage *)image; {
	return [NSImage imageNamed:@"Calculator32x32"];
}

@synthesize dummyLCDView=_dummyLCDView;
@synthesize previewSourceMenu=_previewSourceMenu;
@synthesize previewSourcePopUpButton=_previewSourcePopUpButton;

@synthesize LCDView=_LCDView;

- (IBAction)_previewSourceMenuItemClicked:(id)sender {
	NSURL *documentURL = [sender representedObject];
	
	if ([documentURL isKindOfClass:[NSURL class]]) {
		id document = [[NSDocumentController sharedDocumentController] documentForURL:documentURL];
		
		if ([document isKindOfClass:[WECalculatorDocument class]]) {
			[[self LCDView] setCalculator:[document calculator]];
			[[RSLCDViewManager sharedManager] addLCDView:[self LCDView]];
		}
	}
}

- (IBAction)_choosePreviewSource:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:RSCalculatorRomUTI,RSCalculatorSavestateUTI, nil]];
	[openPanel setPrompt:LOCALIZED_STRING_CHOOSE];
	[openPanel setMessage:NSLocalizedString(@"Choose a source rom or savestate for the preview.", @"Choose a source rom or savestate for the preview")];
	
	[openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
		[openPanel orderOut:nil];
		if (result == NSFileHandlingPanelCancelButton)
			return;
		
		NSError *outError;
		RSCalculator *calculator = [RSCalculator calculatorWithRomOrSavestateURL:[[openPanel URLs] lastObject] error:&outError];
		
		if (!calculator) {
			[[NSApplication sharedApplication] presentError:outError];
			return;
		}
		
		[[self LCDView] setCalculator:calculator];
		[[RSLCDViewManager sharedManager] addLCDView:[self LCDView]];
	}];
}

@end
