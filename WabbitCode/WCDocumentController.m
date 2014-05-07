//
//  WCDocumentController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCDocumentController.h"
#import "WCOpenPanelAccessoryViewController.h"
#import "EncodingManager.h"
#import "WCProjectDocument.h"
#import "WCSourceFileDocument.h"
#import "RSDefines.h"

NSString *const WCAssemblyFileUTI = @"org.revsoft.wabbitcode.assembly";
NSString *const WCIncludeFileUTI = @"org.revsoft.wabbitcode.include";
NSString *const WCActiveServerIncludeFileUTI = @"com.panic.coda.active-server-include-file";
NSString *const WCProjectFileUTI = @"org.revsoft.wabbitcode.project";
NSString *const WCWabbitEditAssemblyFileUTI = @"org.revsoft.wabbitedit.assembly";
NSString *const WCWabbitEditIncludeFileUTI = @"org.revsoft.wabbitedit.include";

@interface WCDocumentController ()
@property (readwrite,retain,nonatomic) WCOpenPanelAccessoryViewController *openPanelAccessoryViewController;
@end

@implementation WCDocumentController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_documentURLsToStringEncodings = [[NSMutableDictionary alloc] initWithCapacity:0];
	_documentURLsToStringEncodingsLock = [[NSLock alloc] init];
	
	[self setAutosavingDelay:15.0];
	
	return self;
}

- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
	[openPanel setAccessoryView:[[self openPanelAccessoryViewController] view]];
	[openPanel setDelegate:self];
	
	NSInteger result = [super runModalOpenPanel:openPanel forTypes:types];
	
	if (result == NSOKButton) {
		NSNumber *stringEncoding = [[[[self openPanelAccessoryViewController] popUpButton] selectedItem] representedObject];
		
		for (NSURL *url in [openPanel URLs]) {
			NSString *type = [self typeForContentsOfURL:url error:NULL];
			if ([type isEqualToString:WCAssemblyFileUTI] ||
				[type isEqualToString:WCIncludeFileUTI] ||
				[type isEqualToString:WCActiveServerIncludeFileUTI]) {
				
				// explicitStringEncodingForDocumentURL: can be called from anywhere, have to lock it up
				[_documentURLsToStringEncodingsLock lock];
				[_documentURLsToStringEncodings setObject:stringEncoding forKey:url];
				[_documentURLsToStringEncodingsLock unlock];
			}
		}
	}
	
	[self setOpenPanelAccessoryViewController:nil];
	
	return result;
}

- (void)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error))completionHandler {	
	NSString *documentType = [self typeForContentsOfURL:url error:NULL];
	
	// if the document type is one of the source file document UTIs, we need to take additional action
	if ([documentType isEqualToString:WCAssemblyFileUTI] ||
		[documentType isEqualToString:WCIncludeFileUTI] ||
		[documentType isEqualToString:WCActiveServerIncludeFileUTI]) {
		
		// for each project document, check each of its source file documents to see if they match "url"
		for (WCProjectDocument *projectDocument in [self projectDocuments]) {			
			for (WCSourceFileDocument *sfDocument in [projectDocument sourceFileDocuments]) {				
				if ([[[sfDocument fileURL] path] isEqualToString:[[url filePathURL] path]]) {
					// if "url" does match the source file document url, open a new tab for the source file inside the project
					[projectDocument openTabForSourceFileDocument:sfDocument tabViewContext:nil];
					return;
				}
			}
		}
	}
	
	[super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
		// if we just opened a project document, perform some additional checks
		if ([documentType isEqualToString:WCProjectFileUTI]) {
			NSArray *projectSourceFileDocuments =  [(WCProjectDocument *)document sourceFileDocuments];
			
			// for each open source file document, loop through the source file documents for the given project document
			for (WCSourceFileDocument *openSourceFileDocument in [self sourceFileDocuments]) {
				for (WCSourceFileDocument *projectSourceFileDocument in projectSourceFileDocuments) {
					// does the source file document url match the source file document url within the project document?
					if ([[[openSourceFileDocument fileURL] path] isEqualToString:[[projectSourceFileDocument fileURL] path]]) {
						// close the source file document, we can't have two source file documents representing the same file
						[openSourceFileDocument close];
						break;
					}
				}
			}
		}
		
		// call the original completion handler
		completionHandler(document,documentWasAlreadyOpen,error);
	}];
}

#pragma mark NSOpenSavePanelDelegate
- (void)panelSelectionDidChange:(id)sender {
	NSArray *URLs = [sender URLs];
	
	// always enable the encoding pop up when there are multiple items selected
	if ([URLs count] > 1) {
		[[[self openPanelAccessoryViewController] popUpButton] setEnabled:YES];
		return;
	}
	else if ([URLs count] == 1) {
		NSString *documentType = [self typeForContentsOfURL:[URLs lastObject] error:NULL];
		
		// if there is only one item selected and its a source file document UTI, enable the pop up
		if ([documentType isEqualToString:WCAssemblyFileUTI] ||
			[documentType isEqualToString:WCIncludeFileUTI] ||
			[documentType isEqualToString:WCActiveServerIncludeFileUTI]) {
			
			[[[self openPanelAccessoryViewController] popUpButton] setEnabled:YES];
			return;
		}
	}
	
	// text encoding doesnt apply to the selected item, disable the pop up (i.e. for project documents)
	[[[self openPanelAccessoryViewController] popUpButton] setEnabled:NO];
}

#pragma mark *** Public Methods ***
- (NSStringEncoding)explicitStringEncodingForDocumentURL:(NSURL *)documentURL; {
	NSNumber *stringEncoding;
	
	// have to lock to make sure background document opening works correctly
	[_documentURLsToStringEncodingsLock lock];
	stringEncoding = [_documentURLsToStringEncodings objectForKey:documentURL];
	[_documentURLsToStringEncodingsLock unlock];
	
	if (!stringEncoding)
		return NoStringEncoding;
	return [stringEncoding unsignedIntegerValue];
}
#pragma mark Properties
@dynamic recentProjectURLs;
- (NSArray *)recentProjectURLs {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	for (NSURL *documentURL in [self recentDocumentURLs]) {
		if ([[self typeForContentsOfURL:documentURL error:NULL] isEqualToString:WCProjectFileUTI])
			[retval addObject:documentURL];
	}
	
	return [[retval copy] autorelease];
}
@dynamic sourceFileDocumentUTIs;
- (NSSet *)sourceFileDocumentUTIs {
	static NSSet *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSSet alloc] initWithObjects:WCAssemblyFileUTI,WCIncludeFileUTI,WCActiveServerIncludeFileUTI,WCWabbitEditAssemblyFileUTI,WCWabbitEditIncludeFileUTI,@"com.mips.mips-assembler",@"com.macromates.textmate.include-file", nil];
	});
	return retval;
}
@dynamic projectDocuments;
- (NSArray *)projectDocuments {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	for (id document in [self documents]) {
		if ([document isKindOfClass:[WCProjectDocument class]])
			[retval addObject:document];
	}
	
	return [[retval copy] autorelease];
}
@dynamic sourceFileDocuments;
- (NSArray *)sourceFileDocuments {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	for (id document in [self documents]) {
		if ([document isKindOfClass:[WCSourceFileDocument class]])
			[retval addObject:document];
	}
	
	return [[retval copy] autorelease];
}
@dynamic currentProjectDocument;
- (WCProjectDocument *)currentProjectDocument {
	id currentDocument = [self currentDocument];
	
	if ([currentDocument isKindOfClass:[WCProjectDocument class]])
		return currentDocument;
	return nil;
}

@synthesize openPanelAccessoryViewController=_openPanelAccessoryViewController;
- (WCOpenPanelAccessoryViewController *)openPanelAccessoryViewController {
	if (!_openPanelAccessoryViewController)
		_openPanelAccessoryViewController = [[WCOpenPanelAccessoryViewController alloc] init];
	return _openPanelAccessoryViewController;
}

@end
