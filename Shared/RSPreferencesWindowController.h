//
//  RSPreferencesWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 7/13/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSPreferencesModule.h"

extern NSString *const RSPreferencesWindowControllerLastSelectedToolbarIdentifierKey;

@interface RSPreferencesWindowController : NSWindowController <NSToolbarDelegate,NSAnimationDelegate> {
	NSMutableArray *_viewControllers;
	NSMutableDictionary *_identifiersToToolbarItems;
	id <RSPreferencesModule> _currentPreferenceModule;
	NSViewAnimation *_swapAnimation;
}
@property (readonly,nonatomic) NSArray *viewControllers;
@property (readonly,nonatomic) NSDictionary *identifiersToToolbarItems;
@property (readwrite,assign,nonatomic) id <RSPreferencesModule> currentPreferenceModule;

+ (id)sharedWindowController;
+ (NSString *)windowNibName;

- (void)setupViewControllers;
- (void)addViewController:(id <RSPreferencesModule>)viewController;
@end
