//
//  WCBuildController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCProjectDocument;

@interface WCBuildController : NSObject {
	__weak WCProjectDocument *_projectDocument;
	NSTask *_task;
	NSMutableString *_output;
	struct {
		unsigned int building:1;
		unsigned int runAfterBuilding:1;
		unsigned int RESERVED:30;		
	} _buildFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,assign,nonatomic,getter = isBuilding) BOOL building;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)build;
- (void)buildAndRun;
@end
