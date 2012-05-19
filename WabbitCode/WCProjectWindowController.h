//
//  WCProjectWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>
#import "RSNavigatorControlDataSource.h"
#import "RSNavigatorControlDelegate.h"
#import "WCProjectDocumentSettingsProvider.h"
#import "WCTabViewControllerDelegate.h"
#import "WCTabViewContext.h"

extern NSString *const WCProjectWindowToolbarBuildItemIdentifier;

extern NSString *const WCProjectWindowNavigatorControlProjectItemIdentifier;
extern NSString *const WCProjectWindowNavigatorControlSymbolItemIdentifier;
extern NSString *const WCProjectWindowNavigatorControlSearchItemIdentifier;
extern NSString *const WCProjectWindowNavigatorControlIssueItemIdentifier;
extern NSString *const WCProjectWindowNavigatorControlBreakpointItemIdentifier;

@class WCProjectNavigatorViewController,WCTabViewController,WCSearchNavigatorViewController,WCIssueNavigatorViewController,WCSymbolNavigatorViewController,WCBreakpointNavigatorViewController,WCConsoleViewController;

@interface WCProjectWindowController : NSWindowController <WCTabViewControllerDelegate,WCProjectDocumentSettingsProvider,RSNavigatorControlDataSource,RSNavigatorControlDelegate,WCTabViewContext,NSSplitViewDelegate,NSWindowDelegate,NSToolbarDelegate> {
	NSMutableArray *_navigatorItemDictionaries;
	WCProjectNavigatorViewController *_projectNavigatorViewController;
	WCSearchNavigatorViewController *_searchNavigatorViewController;
	WCIssueNavigatorViewController *_issueNavigatorViewController;
	WCSymbolNavigatorViewController *_symbolNavigatorViewController;
	WCBreakpointNavigatorViewController *_breakpointNavigatorViewController;
    WCConsoleViewController *_consoleViewController;
	WCTabViewController *_tabViewController;
}
@property (readwrite,assign,nonatomic) IBOutlet RSNavigatorControl *navigatorControl;
@property (readwrite,assign,nonatomic) IBOutlet NSSplitView *splitView;

@property (readonly,nonatomic) WCProjectNavigatorViewController *projectNavigatorViewController;
@property (readonly,nonatomic) WCTabViewController *tabViewController;
@property (readonly,nonatomic) WCSearchNavigatorViewController *searchNavigatorViewController;
@property (readonly,nonatomic) WCIssueNavigatorViewController *issueNavigatorViewController;
@property (readonly,nonatomic) WCSymbolNavigatorViewController *symbolNavigatorViewController;
@property (readonly,nonatomic) WCBreakpointNavigatorViewController *breakpointNavigatorViewController;
@property (readonly,nonatomic) WCConsoleViewController *consoleViewController;

- (IBAction)showProjectNavigator:(id)sender;
- (IBAction)showSymbolNavigator:(id)sender;
- (IBAction)showSearchNavigator:(id)sender;
- (IBAction)showIssueNavigator:(id)sender;
- (IBAction)showBreakpointNavigator:(id)sender;
- (IBAction)showDebugNavigator:(id)sender;
- (IBAction)showBookmarkNavigator:(id)sender;

- (IBAction)selectNextTab:(id)sender;
- (IBAction)selectPreviousTab:(id)sender;

@end
