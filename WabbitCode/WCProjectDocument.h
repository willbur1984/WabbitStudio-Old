//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSDocument.h>
#import "WCOpenQuicklyDataSource.h"
#import "WCTabViewContext.h"

extern NSString *const WCProjectDocumentFileReferencesKey;
extern NSString *const WCProjectDocumentProjectContainerKey;
extern NSString *const WCProjectDocumentBuildTargetsKey;
extern NSString *const WCProjectDocumentFileBreakpointsKey;

extern NSString *const WCProjectDataFileName;
extern NSString *const WCProjectSettingsFileExtension;

@class WCProjectContainer,WCProjectWindowController,WCSourceTextViewController,WCFile,WCSourceFileDocument,WCFileContainer,WCSourceFileSeparateWindowController,NDMutableTrie,NDTrie,WCBuildTarget,WCBuildController,WCBreakpointManager,WCDebugController,WCCalculatorWindowController;

@interface WCProjectDocument : NSDocument <WCOpenQuicklyDataSource> {
	WCProjectContainer *_projectContainer;
	NSMapTable *_filesToSourceFileDocuments;
	NSMapTable *_sourceFileDocumentsToFiles;
	NSMapTable *_filesToFileContainers;
	NSMutableDictionary *_UUIDsToFiles;
	NSHashTable *_unsavedFiles;
	NSCountedSet *_openFiles;
	NSHashTable *_projectSettingsProviders;
	NSDictionary *_projectSettings;
	NDMutableTrie *_fileCompletions;
	NSMutableArray *_buildTargets;
	WCBuildController *_buildController;
	WCBreakpointManager *_breakpointManager;
	WCDebugController *_debugController;
}
@property (readonly,retain) WCProjectContainer *projectContainer;
@property (readonly,retain) NSMapTable *filesToSourceFileDocuments;
@property (readonly,retain) NSMapTable *sourceFileDocumentsToFiles;
@property (readonly,nonatomic) NSArray *sourceFileDocuments;
@property (readonly,nonatomic) NSDictionary *filePathsToFiles;
@property (readonly,nonatomic) NSSet *filePaths;
@property (readonly,retain) NSMapTable *filesToFileContainers; 
@property (readonly,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) NSHashTable *unsavedFiles;
@property (readonly,nonatomic) NSCountedSet *openFiles;
@property (readonly,nonatomic) NSArray *openSourceFileDocuments;
@property (readonly,retain) NSMutableDictionary *UUIDsToFiles;
@property (readonly,copy) NSDictionary *projectSettings;
@property (readonly,retain) NSHashTable *projectSettingsProviders;
@property (readonly,retain) NDTrie *fileCompletions;
@property (readonly,retain) NSArray *buildTargets;
@property (readonly,nonatomic) NSMutableArray *mutableBuildTargets;
@property (readwrite,retain,nonatomic) WCBuildTarget *activeBuildTarget;
@property (readonly,nonatomic) WCBuildController *buildController;
@property (readonly,nonatomic) WCBreakpointManager *breakpointManager;
@property (readonly,nonatomic) WCDebugController *debugController;
@property (readonly,nonatomic) WCCalculatorWindowController *calculatorWindowController;

- (WCFileContainer *)fileContainerForFile:(WCFile *)file;

- (WCSourceTextViewController *)openTabForFile:(WCFile *)file tabViewContext:(id<WCTabViewContext>)tabViewContext;
- (WCSourceTextViewController *)openTabForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument tabViewContext:(id<WCTabViewContext>)tabViewContext;
- (id<WCTabViewContext>)currentTabViewContext;

- (WCSourceFileSeparateWindowController *)openSeparateEditorForFile:(WCFile *)file;
- (WCSourceFileSeparateWindowController *)openSeparateEditorForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (WCSourceFileSeparateWindowController *)createSeparateEditorForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

- (IBAction)openQuickly:(id)sender;

- (IBAction)build:(id)sender;
- (IBAction)buildAndRun:(id)sender;

- (IBAction)editActiveBuildTarget:(id)sender;
- (IBAction)manageBuildTargets:(id)sender;

- (IBAction)findInProject:(id)sender;

- (IBAction)toggleBreakpoints:(id)sender;
- (IBAction)toggleIssues:(id)sender;

- (IBAction)changeRomOrSavestateForRunning:(id)sender;
@end
