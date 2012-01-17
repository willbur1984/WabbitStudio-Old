//
//  WCKeyBindingsEditCommandPairWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingsEditCommandPairWindowController.h"
#import "WCKeyBindingCommandPair.h"
#import "WCPreferencesWindowController.h"
#import "NSApplication+RSExtensions.h"
#import "SRRecorderControl.h"

@interface WCKeyBindingsEditCommandPairWindowController ()
@property (readwrite,retain,nonatomic) WCKeyBindingCommandPair *commandPair;
@end

@implementation WCKeyBindingsEditCommandPairWindowController
- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCKeyBindingsEditCommandPairWindow";
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	[[self recorderControl] setAllowsKeyOnly:NO escapeKeysRecord:YES];
	[[self recorderControl] setStyle:SRGreyStyle];
}

#pragma mark SRRecorderDelegate
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
	
}


+ (WCKeyBindingsEditCommandPairWindowController *)sharedWindowController {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (void)showEditCommandPairSheetForCommandPair:(WCKeyBindingCommandPair *)commandPair; {
	[self setCommandPair:commandPair];
	
	[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[WCPreferencesWindowController sharedWindowController] window] didEndBlock:^(NSInteger returnCode) {
		if (returnCode == NSOKButton) {
			[[self commandPair] setKeyCombo:[[self recorderControl] keyCombo]];
		}
		[self setCommandPair:nil];
	}];
}

- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
	[[self window] orderOut:nil];
}
- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
	[[self window] orderOut:nil];
}

@synthesize commandPair=_commandPair;
@synthesize recorderControl=_recorderControl;

@end
