//
//  WCProjectNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JAViewController.h"
#import "RSOutlineView.h"
#import "RSFindOptionsViewControllerDelegate.h"
#import "WCNavigatorModule.h"
#import "WCProjectDocumentSettingsProvider.h"
#import <Quartz/Quartz.h>

extern NSString *const WCProjectNavigatorDidAddNewGroupNotification;
extern NSString *const WCProjectNavigatorDidAddNewGroupNotificationNewGroupUserInfoKey;

extern NSString *const WCProjectNavigatorDidAddNodesNotification;
extern NSString *const WCProjectNavigatorDidAddNodesNotificationNewNodesUserInfoKey;

extern NSString *const WCProjectNavigatorDidGroupNodesNotification;
extern NSString *const WCProjectNavigatorDidGroupNodesNotificationGroupedNodesUserInfoKey;

extern NSString *const WCProjectNavigatorDidRemoveNodesNotification;
extern NSString *const WCProjectNavigatorDidRemoveNodesNotificationRemovedNodesUserInfoKey;

extern NSString *const WCProjectNavigatorDidUngroupNodesNotification;
extern NSString *const WCProjectNavigatorDidUngroupNodesNotificationUngroupedNodesUserInfoKey;

extern NSString *const WCProjectNavigatorDidRenameNodeNotification;
extern NSString *const WCProjectNavigatorDidRenameNodeNotificationRenamedNodeUserInfoKey;

extern NSString *const WCProjectNavigatorDidMoveNodesNotification;
extern NSString *const WCProjectNavigatorDidMoveNodesNotificationMovedNodesUserInfoKey;

@class WCProjectContainer,RSFindOptionsViewController,WCProjectDocument,WCAddToProjectAccessoryViewController;

@interface WCProjectNavigatorViewController : NSViewController <WCProjectDocumentSettingsProvider,WCNavigatorModule,RSOutlineViewDelegate,RSFindOptionsViewControllerDelegate,QLPreviewPanelDataSource,QLPreviewPanelDelegate,NSOpenSavePanelDelegate> {
	__unsafe_unretained WCProjectDocument *_projectDocument;
	WCProjectContainer *_projectContainer;
	WCProjectContainer *_filteredProjectContainer;
	NSString *_filterString;
	RSFindOptionsViewController *_filterOptionsViewController;
	NSArray *_expandedItemsBeforeFilterOperation;
	NSArray *_selectedItemsBeforeFilterOperation;
	NSArray *_selectedItemsAfterFilterOperation;
	WCAddToProjectAccessoryViewController *_addToProjectAccessoryViewController;
	NSSet *_projectFilePaths;
	struct {
		unsigned int switchTreeControllerContentBinding:1;
		unsigned int ignoreChangesToProjectDocumentSettings:1;
		unsigned int RESERVED:30;
	} _projectNavigatorFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;

@property (readonly,nonatomic) WCProjectContainer *projectContainer;
@property (readwrite,copy,nonatomic) NSString *filterString;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (IBAction)filter:(id)sender;
- (IBAction)toggleFilterOptions:(id)sender;
- (IBAction)showFilterOptions:(id)sender;
- (IBAction)hideFilterOptions:(id)sender;

- (IBAction)addFilesToProject:(id)sender;

- (IBAction)showInFinder:(id)sender;
- (IBAction)openWithExternalEditor:(id)sender;

- (IBAction)newGroup:(id)sender;
- (IBAction)newGroupFromSelection:(id)sender;
- (IBAction)ungroupSelection:(id)sender;

- (IBAction)delete:(id)sender;
- (IBAction)rename:(id)sender;

- (IBAction)openInSeparateEditor:(id)sender;

- (IBAction)moveFocusToNextArea:(id)sender;
- (IBAction)moveFocusToPreviousArea:(id)sender;
@end
