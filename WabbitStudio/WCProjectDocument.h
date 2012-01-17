//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>
#import "WCOpenQuicklyDataSource.h"

@class WCProjectContainer,WCProjectWindowController,WCSourceTextViewController,WCFile,WCSourceFileDocument;

@interface WCProjectDocument : NSDocument <WCOpenQuicklyDataSource> {
	WCProjectContainer *_projectContainer;
	NSMapTable *_filesToSourceFileDocuments;
	NSMapTable *_sourceFileDocumentsToFiles;
}
@property (readonly,retain) WCProjectContainer *projectContainer;
@property (readonly,retain) NSMapTable *filesToSourceFileDocuments;
@property (readonly,retain) NSMapTable *sourceFileDocumentsToFiles;
@property (readonly,nonatomic) NSArray *sourceFileDocuments;

@property (readonly,nonatomic) WCProjectWindowController *projectWindowController;

- (WCSourceTextViewController *)openTabForFile:(WCFile *)file;
- (WCSourceTextViewController *)openTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

- (IBAction)openQuickly:(id)sender;
@end
