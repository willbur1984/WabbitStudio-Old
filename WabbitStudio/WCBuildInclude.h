//
//  WCBuildInclude.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"
#import "RSFileReferenceDelegate.h"

@class RSFileReference;

@interface WCBuildInclude : RSObject <RSFileReferenceDelegate,RSPlistArchiving,NSCopying,NSMutableCopying> {
	RSFileReference *_fileReference;
}
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSImage *icon;
@property (readonly,nonatomic) NSString *path;
@property (readwrite,retain,nonatomic) RSFileReference *fileReference;

+ (id)buildIncludeWithDirectoryURL:(NSURL *)directoryURL;
- (id)initWithDirectoryURL:(NSURL *)directoryURL;

@end
