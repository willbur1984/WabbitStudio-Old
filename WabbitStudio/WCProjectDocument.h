//
//  WCProjectDocument.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>

@class RSTreeNode;

@interface WCProjectDocument : NSDocument {
	RSTreeNode *_projectNode;
}
@property (readonly,retain) RSTreeNode *projectNode;
@end
