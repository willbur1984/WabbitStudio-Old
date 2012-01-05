//
//  WCAdvancedViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

@interface WCAdvancedViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider,NSSplitViewDelegate> {
	NSMutableArray *_viewControllers;
	NSMutableSet *_identifiers;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *splitterHandleImageView;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet NSTabView *tabView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *arrayController;

@property (readonly,nonatomic) NSArray *viewControllers;

- (void)addViewController:(id <RSPreferencesModule>)viewController;
@end
