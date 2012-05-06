//
//  WCBuildController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/NSObject.h>

extern NSString *const WCBuildControllerDidFinishBuildingNotification;

extern NSString *const WCBuildControllerDidChangeBuildIssueVisibleNotification;
extern NSString *const WCBuildControllerDidChangeBuildIssueVisibleChangedBuildIssueUserInfoKey;

extern NSString *const WCBuildControllerDidChangeAllBuildIssuesVisibleNotification;

@class WCProjectDocument;

@interface WCBuildController : NSObject {
	__weak WCProjectDocument *_projectDocument;
	NSTask *_task;
	NSMutableString *_output;
	NSMapTable *_filesToBuildIssuesSortedByLocation;
	NSArray *_filesWithBuildIssuesSortedByName;
	NSSet *_buildIssues;
	NSUInteger _totalErrors;
	NSUInteger _totalWarnings;
	NSURL *_lastOutputFileURL;
	struct {
		unsigned int building:1;
		unsigned int runAfterBuilding:1;
		unsigned int issuesEnabled;
		unsigned int changingVisibilityOfAllBuildIssues:1;
		unsigned int RESERVED:28;		
	} _buildFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,assign,nonatomic,getter = isBuilding) BOOL building;
@property (readonly,copy,nonatomic) NSArray *filesWithBuildIssuesSortedByName;
@property (readonly,retain,nonatomic) NSMapTable *filesToBuildIssuesSortedByLocation;
@property (readwrite,assign,nonatomic) BOOL issuesEnabled;
@property (readonly,assign,nonatomic) NSUInteger totalErrors;
@property (readonly,assign,nonatomic) NSUInteger totalWarnings;
@property (readonly,copy,nonatomic) NSURL *lastOutputFileURL;
@property (readwrite,assign,nonatomic) BOOL runAfterBuilding;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)build;
- (void)buildAndRun;

- (void)performCleanup;
@end
