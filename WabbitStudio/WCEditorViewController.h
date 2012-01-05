//
//  WCEditorViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

extern NSString *const WCEditorShowCurrentLineHighlightKey;
extern NSString *const WCEditorShowLineNumbersKey;
extern NSString *const WCEditorShowMatchingBraceHighlightKey;
extern NSString *const WCEditorShowMatchingTemporaryLabelHighlightKey;
extern NSString *const WCEditorAutomaticallyInsertMatchingBraceKey;
extern NSString *const WCEditorSuggestCompletionsWhileTypingKey;
extern NSString *const WCEditorSuggestCompletionsWhileTypingDelayKey;
extern NSString *const WCEditorAutomaticallyIndentAfterNewlinesKey;

@interface WCEditorViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@end
