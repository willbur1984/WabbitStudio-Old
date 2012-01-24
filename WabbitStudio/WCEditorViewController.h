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
extern NSString *const WCEditorShowCodeFoldingRibbonKey;
extern NSString *const WCEditorShowInvisibleCharactersKey;
extern NSString *const WCEditorShowLineNumbersKey;
extern NSString *const WCEditorShowMatchingBraceHighlightKey;
extern NSString *const WCEditorShowMatchingTemporaryLabelHighlightKey;
extern NSString *const WCEditorShowHighlightEnclosedMacroArgumentsKey;
extern NSString *const WCEditorShowHighlightEnclosedMacroArgumentsDelayKey;
extern NSString *const WCEditorAutomaticallyInsertMatchingBraceKey;
extern NSString *const WCEditorSuggestCompletionsWhileTypingKey;
extern NSString *const WCEditorSuggestCompletionsWhileTypingDelayKey;
extern NSString *const WCEditorAutomaticallyIndentAfterNewlinesKey;
extern NSString *const WCEditorAutomaticallyIndentAfterLabelsKey;
extern NSString *const WCEditorWrapLinesToEditorWidthKey;
typedef enum _WCEditorIndentUsing {
	WCEditorIndentUsingSpaces = 0,
	WCEditorIndentUsingTabs = 1
	
} WCEditorIndentUsing;
extern NSString *const WCEditorIndentUsingKey;
extern NSString *const WCEditorTabWidthKey;
extern NSString *const WCEditorShowPageGuideAtColumnKey;
extern NSString *const WCEditorPageGuideColumnNumberKey;
typedef enum _WCEditorDefaultLineEndings {
	WCEditorDefaultLineEndingsUnix = 0,
	WCEditorDefaultLineEndingsMacOS = 1,
	WCEditorDefaultLineEndingsWindows = 2
	
} WCEditorDefaultLineEndings;
extern NSString *const WCEditorDefaultLineEndingsKey;
extern NSString *const WCEditorConvertExistingFileLineEndingsOnSaveKey;
extern NSString *const WCEditorDefaultTextEncodingKey;

@interface WCEditorViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSPopUpButton *popUpButton;

- (IBAction)changeDefaultTextEncoding:(id)sender;
@end
