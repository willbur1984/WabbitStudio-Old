//
//  WCProjectTemplate.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplate.h"

extern NSString *const WCProjectTemplateInfoIncludeFilesKey;

@interface WCProjectTemplate : WCTemplate
@property (readonly,nonatomic) NSArray *includeFiles;

+ (id)projectTemplateWithURL:(NSURL *)url;
@end
