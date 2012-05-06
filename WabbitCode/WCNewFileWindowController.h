//
//  WCNewFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSWindowController.h>
#import "RSCollectionViewDelegate.h"
#import "RSTableViewDelegate.h"

@class WCFileTemplate,WCProjectDocument;

@interface WCNewFileWindowController : NSWindowController <RSCollectionViewDelegate,RSTableViewDelegate,NSSplitViewDelegate> {
	__weak WCProjectDocument *_projectDocument;
	NSMutableArray *_categories;
	NSURL *_savePanelURL;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
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
