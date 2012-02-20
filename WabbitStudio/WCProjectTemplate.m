//
//  WCProjectTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectTemplate.h"

NSString *const WCProjectTemplateInfoIncludeFilesKey = @"includeFiles";

@implementation WCProjectTemplate
+ (id)projectTemplateWithURL:(NSURL *)url; {
	return [self templateWithURL:url error:NULL];
}

@dynamic includeFiles;
- (NSArray *)includeFiles {
	return [[self info] objectForKey:WCProjectTemplateInfoIncludeFilesKey];
}

@end
