//
//  WCKeyBindingsEditCommandPairWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCKeyBindingsEditCommandPairWindowController.h"
#import "WCKeyBindingCommandPair.h"
#import "WCPreferencesWindowController.h"
#import "NSApplication+RSExtensions.h"
#import "SRRecorderControl.h"

@interface WCKeyBindingsEditCommandPairWindowController ()
@property (readwrite,retain,nonatomic) WCKeyBindingCommandPair *commandPair;
@end

@implementation WCKeyBindingsEditCommandPairWindowController
#pragma mark *** Subclass Overrides ***
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

#pragma mark *** Public Methods ***
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
#pragma mark IBActions
- (IBAction)ok:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
	[[self window] orderOut:nil];
}
- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
	[[self window] orderOut:nil];
}
#pragma mark Properties
@synthesize commandPair=_commandPair;
@synthesize recorderControl=_recorderControl;

@end
