//
//  WCBuildController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

extern NSString *const WCBuildControllerDidFinishBuildingNotification;

extern NSString *const WCBuildControllerDidChangeBuildIssueVisibleNotification;
extern NSString *const WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey;

@class WCProjectDocument;

@interface WCBuildController : NSObject {
	__weak WCProjectDocument *_projectDocument;
	NSTask *_task;
	NSMutableString *_output;
	NSMapTable *_filesToBuildIssuesSortedByLocation;
	NSArray *_filesWithBuildIssuesSortedByName;
	NSSet *_buildIssues;
	struct {
		unsigned int building:1;
		unsigned int runAfterBuilding:1;
		unsigned int RESERVED:30;		
	} _buildFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,assign,nonatomic,getter = isBuilding) BOOL building;
@property (readonly,copy,nonatomic) NSArray *filesWithBuildIssuesSortedByName;
@property (readonly,retain,nonatomic) NSMapTable *filesToBuildIssuesSortedByLocation;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)build;
- (void)buildAndRun;

- (void)performCleanup;
@end
