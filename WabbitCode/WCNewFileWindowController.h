//
//  WCNewFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCFileTemplate,WCProjectDocument;

@interface WCNewFileWindowController : NSWindowController {
	__weak WCProjectDocument *_projectDocument;
	NSMutableArray *_categories;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *categoriesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSCollectionView *collectionView;
@property (readwrite,assign,nonatomic) IBOutlet NSImageView *splitterHandleImageView;

@property (readonly,nonatomic) NSArray *categories;
@property (readonly,nonatomic) NSMutableArray *mutableCategories;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;

+ (WCNewFileWindowController *)sharedWindowController;

+ (id)newFileWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)showNewFileWindow;

- (IBAction)cancel:(id)sender;
- (IBAction)create:(id)sender;
@end
