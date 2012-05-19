//
//  WCEditorViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

extern NSString *const WCEditorShowCurrentLineHighlightKey;
extern NSString *const WCEditorShowCodeFoldingRibbonKey;
extern NSString *const WCEditorFocusFollowsSelectionKey;
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
@property (readwrite,assign,nonatomic) IBOutlet NSStepper *highlightEnclosedMacroArgumentsDelayStepper;
@property (readwrite,assign,nonatomic) IBOutlet NSStepper *suggestCompletionsDelayStepper;

- (IBAction)changeDefaultTextEncoding:(id)sender;
@end
