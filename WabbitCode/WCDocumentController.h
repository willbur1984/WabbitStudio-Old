//
//  WCDocumentController.h
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocumentController.h>

extern NSString *const WCAssemblyFileUTI;
extern NSString *const WCIncludeFileUTI;
extern NSString *const WCActiveServerIncludeFileUTI;
extern NSString *const WCProjectFileUTI;

@class WCOpenPanelAccessoryViewController,WCProjectDocument;

@interface WCDocumentController : NSDocumentController <NSOpenSavePanelDelegate> {
	NSMutableDictionary *_documentURLsToStringEncodings;
	NSLock *_documentURLsToStringEncodingsLock;
	WCOpenPanelAccessoryViewController *_openPanelAccessoryViewController;
}
@property (readonly,nonatomic) NSArray *recentProjectURLs;
@property (readonly,nonatomic) NSSet *sourceFileDocumentUTIs;
@property (readonly,nonatomic) NSArray *projectDocuments;
@property (readonly,nonatomic) NSArray *sourceFileDocuments;
@property (readonly,nonatomic) WCProjectDocument *currentProjectDocument;

- (NSStringEncoding)explicitStringEncodingForDocumentURL:(NSURL *)documentURL;

@end
