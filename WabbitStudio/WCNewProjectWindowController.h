//
//  WCNewProjectWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@interface WCNewProjectWindowController : NSWindowController <NSTableViewDelegate> {
	NSMutableArray *_categories;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *categoriesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSCollectionView *collectionView;

@property (readonly,nonatomic) NSArray *categories;
@property (readonly,nonatomic) NSMutableArray *mutableCategories;

+ (WCNewProjectWindowController *)sharedWindowController;

- (IBAction)cancel:(id)sender;
- (IBAction)createFromFolder:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;

- (id)createProjectWithContentsOfDirectory:(NSURL *)directoryURL error:(NSError **)outError;
@end
