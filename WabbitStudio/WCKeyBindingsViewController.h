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

extern NSString *const WCKeyBindingsUserCommandSetIdentifiersKey;

@interface WCKeyBindingsViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider,MGScopeBarDelegate,NSOutlineViewDelegate> {
	NSArray *_scopeBarItemTitles;
	NSDictionary *_scopeBarItemIdentifiersToTitles;
	NSString *_searchString;
}
@property (readwrite,assign,nonatomic) IBOutlet MGScopeBar *scopeBar;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *searchArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;

@property (readonly,copy,nonatomic) NSString *searchString;

- (IBAction)search:(id)sender;
@end
