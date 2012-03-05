//
//  WCNewFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCFileTemplate,WCProjectDocument;

@interface WCNewFileWindowController : NSWindowController <NSTableViewDelegate,NSSplitViewDelegate> {
	__weak WCProjectDocument *_projectDocument;
	NSMutableArray *_categories;
	NSURL *_savePanelURL;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *categoriesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSCollectionView *collectionView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *splitterHandleImageView;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *templatesArrayController;

@property (readonly,nonatomic) NSArray *categories;
@property (readonly,nonatomic) NSMutableArray *mutableCategories;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;

+ (WCNewFileWindowController *)sharedWindowController;

+ (id)newFileWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)showNewFileWindow;

- (BOOL)createFileAtURL:(NSURL *)fileURL withFileTemplate:(WCFileTemplate *)fileTemplate error:(NSError **)outError;

- (IBAction)cancel:(id)sender;
- (IBAction)create:(id)sender;
@end
