//
//  WCBreakpointManager.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

extern NSString *const WCBreakpointManagerDidAddFileBreakpointNotification;
extern NSString *const WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey;

extern NSString *const WCBreakpointManagerDidRemoveFileBreakpointNotification;
extern NSString *const WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey;

extern NSString *const WCBreakpointManagerDidChangeBreakpointActiveNotification;
extern NSString *const WCBreakpointManagerDidChangeBreakpointActiveChangedBreakpointUserInfoKey;

extern NSString *const WCBreakpointManagerDidChangeBreakpointsEnabledNotification;

@class WCProjectDocument,WCFileBreakpoint;

@interface WCBreakpointManager : NSObject {
	__weak WCProjectDocument *_projectDocument;
	NSMapTable *_filesToFileBreakpointsSortedByLocation;
	NSMutableArray *_filesWithFileBreakpointsSortedByName;
	NSMutableSet *_fileBreakpoints;
	struct {
		unsigned int breakpointsEnabled:1;
		unsigned int RESERVED:31;
	} _breakpointManagerFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) NSMapTable *filesToFileBreakpointsSortedByLocation;
@property (readonly,nonatomic) NSArray *filesWithFileBreakpointsSortedByName;
@property (readwrite,assign,nonatomic) BOOL breakpointsEnabled;
@property (readonly,nonatomic) NSArray *allFileBreakpoints;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)addFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;
- (void)removeFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;

- (void)performCleanup;
@end
