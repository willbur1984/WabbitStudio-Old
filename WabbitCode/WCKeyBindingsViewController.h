//
//  WCKeyBindingsViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
