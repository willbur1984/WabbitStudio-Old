//
//  WCNewProjectWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSCollectionViewDelegate.h"
#import "RSTableViewDelegate.h"

@class WCProjectTemplate;

@interface WCNewProjectWindowController : NSWindowController <RSCollectionViewDelegate,RSTableViewDelegate,NSSplitViewDelegate> {
	NSMutableArray *_categories;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *categoriesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSCollectionView *collectionView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *splitterHandleImageView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *templatesArrayController;

@property (readonly,nonatomic) NSArray *categories;
@property (readonly,nonatomic) NSMutableArray *mutableCategories;

+ (WCNewProjectWindowController *)sharedWindowController;

- (IBAction)cancel:(id)sender;
- (IBAction)createFromFolder:(id)sender;
- (IBAction)create:(id)sender;

- (id)createProjectWithContentsOfDirectory:(NSURL *)directoryURL error:(NSError **)outError;
- (id)createProjectAtURL:(NSURL *)projectURL withProjectTemplate:(WCProjectTemplate *)projectTemplate error:(NSError **)outError;
@end
