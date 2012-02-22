//
//  WCDocumentController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCDocumentController.h"
#import "WCOpenPanelAccessoryViewController.h"
#import "EncodingManager.h"

NSString *const WCAssemblyFileUTI = @"org.revsoft.wabbitcode.assembly";
NSString *const WCIncludeFileUTI = @"org.revsoft.wabbitcode.include";
NSString *const WCActiveServerIncludeFileUTI = @"com.panic.coda.active-server-include-file";
NSString *const WCProjectFileUTI = @"org.revsoft.wabbitcode.project";

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
		retval = [[NSSet alloc] initWithObjects:WCAssemblyFileUTI,WCIncludeFileUTI,WCActiveServerIncludeFileUTI, nil];
	});
	return retval;
}
@synthesize openPanelAccessoryViewController=_openPanelAccessoryViewController;
- (WCOpenPanelAccessoryViewController *)openPanelAccessoryViewController {
	if (!_openPanelAccessoryViewController)
		_openPanelAccessoryViewController = [[WCOpenPanelAccessoryViewController alloc] init];
	return _openPanelAccessoryViewController;
}

@end
