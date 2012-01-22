//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>
#import "WCOpenQuicklyDataSource.h"

extern NSString *const WCProjectDocumentFileReferencesKey;
extern NSString *const WCProjectDocumentProjectContainerKey;

extern NSString *const WCProjectDataFileName;

@class WCProjectContainer,WCProjectWindowController,WCSourceTextViewController,WCFile,WCSourceFileDocument,WCFileContainer;

@interface WCProjectDocument : NSDocument <WCOpenQuicklyDataSource> {
	WCProjectContainer *_projectContainer;
	NSMapTable *_filesToSourceFileDocuments;
	NSMapTable *_sourceFileDocumentsToFiles;
	NSMapTable *_filesToFileContainers;
	NSHashTable *_unsavedFiles;
	NSCountedSet *_openFiles;
}
@property (readonly,retain) WCProjectContainer *projectContainer;
@property (readonly,retain) NSMapTable *filesToSourceFileDocuments;
@property (readonly,retain) NSMapTable *sourceFileDocumentsToFiles;
@property (readonly,nonatomic) NSArray *sourceFileDocuments;
@property (readonly,nonatomic) NSDictionary *filePathsToFiles;
@property (readonly,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) NSHashTable *unsavedFiles;
@property (readonly,nonatomic) NSCountedSet *openFiles;

- (WCFileContainer *)fileContainerForFile:(WCFile *)file;

- (WCSourceTextViewController *)openTabForFile:(WCFile *)file;
- (WCSourceTextViewController *)openTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

- (IBAction)openQuickly:(id)sender;
@end
