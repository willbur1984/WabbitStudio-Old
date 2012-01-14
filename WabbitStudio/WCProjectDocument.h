//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>

@class WCProjectContainer;

@interface WCProjectDocument : NSDocument {
	WCProjectContainer *_projectContainer;
}
@property (readonly,retain) WCProjectContainer *projectContainer;
@end
