//
//  RSTabViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSViewController.h>
#import "WCProjectDocumentSettingsProvider.h"
#import "WCTabViewControllerDelegate.h"

extern NSString *const WCTabViewControllerDidSelectTabNotification;
extern NSString *const WCTabViewControllerDidCloseTabNotification;

@class PSMTabBarControl,WCSourceFileDocument,WCSourceTextViewController;

@interface WCTabViewController : NSViewController <WCProjectDocumentSettingsProvider,NSTabViewDelegate> {
	__unsafe_unretained id <WCTabViewControllerDelegate> _delegate;
	NSMapTable *_sourceFileDocumentsToSourceTextViewControllers;
	NSTabViewItem *_clickedTabViewItem;
	struct {
		unsigned int ignoreChangesToProjectDocumentSettings:1;
		unsigned int RESERVED:31;
	} _tabViewControllerFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet PSMTabBarControl *tabBarControl;
@property (readwrite,assign,nonatomic) IBOutlet NSTabView *tabView;

@property (readwrite,assign,nonatomic) id <WCTabViewControllerDelegate> delegate;

@property (readonly,nonatomic) NSMapTable *sourceFileDocumentsToSourceTextViewControllers;

- (WCSourceTextViewController *)addTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (void)removeTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

@end
