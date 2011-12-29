//
//  WCFontsAndColorsViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"

extern NSString *const WCFontsAndColorsCurrentThemeIdentifierKey;

@interface WCFontsAndColorsViewController : NSViewController <RSPreferencesModule,RSUserDefaultsProvider,NSWindowDelegate,NSTableViewDelegate> {
	id <NSWindowDelegate> _oldWindowDelegate;
	id _fontPanelWillCloseObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *themesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *pairsArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *themesTableView;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *pairsTableView;

- (IBAction)chooseFont:(id)sender;
@end
