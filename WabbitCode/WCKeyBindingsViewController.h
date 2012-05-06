//
//  WCKeyBindingsViewController.h
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

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"
#import "MGScopeBarDelegateProtocol.h"
#import "RSTableViewDelegate.h"
#import "RSOutlineViewDelegate.h"

extern NSString *const WCKeyBindingsCurrentCommandSetIdentifierKey;
extern NSString *const WCKeyBindingsUserCommandSetIdentifiersKey;

@interface WCKeyBindingsViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider,MGScopeBarDelegate,RSOutlineViewDelegate,RSTableViewDelegate,NSMenuDelegate> {
	NSArray *_scopeBarItemTitles;
	NSDictionary *_scopeBarItemIdentifiersToTitles;
	NSString *_searchString;
	NSString *_defaultShortcutString;
	NSArray *_previousSelectionIndexPaths;
}
@property (readwrite,assign,nonatomic) IBOutlet MGScopeBar *scopeBar;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *searchArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;

@property (readonly,copy,nonatomic) NSString *searchString;
@property (readonly,copy,nonatomic) NSString *defaultShortcutString;

- (IBAction)search:(id)sender;
- (IBAction)deleteCommandSet:(id)sender;
- (IBAction)duplicateCommandSet:(id)sender;
@end
