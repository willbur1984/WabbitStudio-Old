//
//  WCFileBreakpoint.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpoint.h"

@class WCFile,WCProjectDocument;

@interface WCFileBreakpoint : WCBreakpoint <RSPlistArchiving,NSCopying,NSMutableCopying> {
	__weak WCProjectDocument *_projectDocument;
	NSRange _range;
	WCFile *_file;
	NSString *_fileUUID;
}
@property (readwrite,assign,nonatomic) NSRange range;
@property (readonly,nonatomic) WCFile *file;
@property (readwrite,assign,nonatomic) WCProjectDocument *projectDocument;

+ (id)fileBreakpointWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithRange:(NSRange)range file:(WCFile *)file projectDocument:(WCProjectDocument *)projectDocument;
@end
