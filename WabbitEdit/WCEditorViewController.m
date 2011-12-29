//
//  WCEditorViewController.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCEditorViewController.h"

NSString *const WCEditorShowCurrentLineHighlightKey = @"editorShowCurrentLineHighlight";
NSString *const WCEditorShowLineNumbersKey = @"editorShowLineNumbers";

@implementation WCEditorViewController

#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)init {
	return [self initWithNibName:@"WCEditorView" bundle:nil];
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitcode.editor";
}

- (NSString *)label {
	return NSLocalizedString(@"Editor", @"Editor");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"Editor"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCEditorShowCurrentLineHighlightKey,[NSNumber numberWithBool:YES],WCEditorShowLineNumbersKey, nil];
}

@synthesize initialFirstResponder=_initialFirstResponder;
@end
