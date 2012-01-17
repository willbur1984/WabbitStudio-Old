//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>

@class WCProjectContainer,WCProjectWindowController;

@interface WCProjectDocument : NSDocument {
	WCProjectContainer *_projectContainer;
	NSMapTable *_filesToSourceFileDocuments;
}
@property (readonly,retain) WCProjectContainer *projectContainer;
@property (readonly,retain) NSMapTable *filesToSourceFileDocuments;
@property (readonly,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) NSArray *sourceFileDocuments;
@end
