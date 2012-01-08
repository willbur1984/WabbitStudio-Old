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
NSString *const WCEditorShowMatchingBraceHighlightKey = @"editorShowMatchingBraceHighlight";
NSString *const WCEditorShowMatchingTemporaryLabelHighlightKey = @"editorShowMatchingTemporaryLabelHighlight";
NSString *const WCEditorAutomaticallyInsertMatchingBraceKey = @"editorAutomaticallyInsertMatchingBrace";
NSString *const WCEditorSuggestCompletionsWhileTypingKey = @"editorSuggestCompletionsWhileTyping";
NSString *const WCEditorSuggestCompletionsWhileTypingDelayKey = @"editorSuggestCompletionsWhileTypingDelay";
NSString *const WCEditorAutomaticallyIndentAfterNewlinesKey = @"editorAutomaticallyIndentAfterNewlines";
NSString *const WCEditorWrapLinesToEditorWidthKey = @"editorWrapLinesToEditorWidth";
NSString *const WCEditorIndentUsingKey = @"editorIndentUsing";
NSString *const WCEditorTabWidthKey = @"editorTabWidth";

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
	return @"org.revsoft.wabbitstudio.editor";
}

- (NSString *)label {
	return NSLocalizedString(@"Editor", @"Editor");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"Editor"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCEditorShowCurrentLineHighlightKey,[NSNumber numberWithBool:YES],WCEditorShowLineNumbersKey,[NSNumber numberWithBool:YES],WCEditorShowMatchingBraceHighlightKey,[NSNumber numberWithBool:YES],WCEditorShowMatchingTemporaryLabelHighlightKey,[NSNumber numberWithBool:YES],WCEditorAutomaticallyInsertMatchingBraceKey,[NSNumber numberWithBool:YES],WCEditorSuggestCompletionsWhileTypingKey,[NSNumber numberWithFloat:0.35],WCEditorSuggestCompletionsWhileTypingDelayKey,[NSNumber numberWithBool:YES],WCEditorAutomaticallyIndentAfterNewlinesKey,[NSNumber numberWithBool:YES],WCEditorWrapLinesToEditorWidthKey,[NSNumber numberWithUnsignedInteger:WCEditorIndentUsingTabs],WCEditorIndentUsingKey,[NSNumber numberWithUnsignedInteger:4],WCEditorTabWidthKey, nil];
}

@synthesize initialFirstResponder=_initialFirstResponder;
@end
