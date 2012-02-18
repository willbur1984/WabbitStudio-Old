//
//  WCBreakpointManager.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

extern NSString *const WCBreakpointManagerDidAddBreakpointNotification;
extern NSString *const WCBreakpointManagerDidAddBreakpointNewBreakpointUserInfoKey;

extern NSString *const WCBreakpointManagerDidRemoveBreakpointNotification;
extern NSString *const WCBreakpointManagerDidRemoveBreakpointOldBreakpointUserInfoKey;

extern NSString *const WCBreakpointManagerDidChangeBreakpointActiveNotification;

@class WCProjectDocument,WCFileBreakpoint;

@interface WCBreakpointManager : NSObject {
	__weak WCProjectDocument *_projectDocument;
	NSMapTable *_filesToFileBreakpointsSortedByLocation;
	NSMutableArray *_filesWithFileBreakpointsSortedByName;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) NSMapTable *filesToFileBreakpointsSortedByLocation;
@property (readonly,nonatomic) NSArray *filesWithFileBreakpointsSortedByName;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)addFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;
- (void)removeFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint;

@end
