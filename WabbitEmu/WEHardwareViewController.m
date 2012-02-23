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
	[menu addItemWithTitle:NSLocalizedString(@"Choose Source\u2026", @"Choose Source with ellipsis") action:@selector(_choosePreviewSource:) keyEquivalent:@""];
	[[[menu itemArray] lastObject] setTarget:self];
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
	
}

@end
