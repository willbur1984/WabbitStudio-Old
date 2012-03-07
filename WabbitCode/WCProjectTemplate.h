//
//  WCProjectTemplate.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplate.h"
#import "WCBuildTarget.h"

extern NSString *const WCProjectTemplateInfoIncludeFileNamesKey;
extern NSString *const WCProjectTemplateInfoOutputTypeKey;

@interface WCProjectTemplate : WCTemplate

@property (readonly,nonatomic) NSArray *includeFiles;
@property (readonly,nonatomic) WCBuildTargetOutputType outputType;

+ (id)projectTemplateWithURL:(NSURL *)url;
@end
