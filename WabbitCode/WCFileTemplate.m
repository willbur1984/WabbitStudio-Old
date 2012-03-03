//
//  WCFileTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFileTemplate.h"

NSString *const WCFileTemplateProjectNamePlaceholder = @"__PROJECT_NAME__";
NSString *const WCFileTemplateFileNamePlaceholder = @"__FILE_NAME__";
NSString *const WCFileTemplateFullUserNamePlaceholder = @"__FULL_USER_NAME__";
NSString *const WCFileTemplateDatePlaceholder = @"__DATE__";
NSString *const WCFileTemplateIncludeFileNamesPlaceholder = @"__INCLUDE_FILE_NAMES__";

NSString *const WCFileTemplateProjectNameValueKey = @"WCFileTemplateProjectNameValueKey";
NSString *const WCFileTemplateFileNameValueKey = @"WCFileTemplateFileNameValueKey";
NSString *const WCFileTemplateIncludeFileNamesValueKey = @"WCFileTemplateIncludeFileNamesValueKey";

NSString *const WCFileTemplateAllowedFileTypesInfoKey = @"allowedFileTypes";

@implementation WCFileTemplate

+ (id)fileTemplateWithURL:(NSURL *)url error:(NSError **)outError; {
	return [self templateWithURL:url error:outError];
}

@dynamic allowedFileTypes;
- (NSArray *)allowedFileTypes {
	return [[self info] objectForKey:WCFileTemplateAllowedFileTypesInfoKey];
}

@end
