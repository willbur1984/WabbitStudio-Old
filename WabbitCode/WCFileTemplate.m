//
//  WCFileTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
#pragma mark *** Public Methods ***
+ (id)fileTemplateWithURL:(NSURL *)url error:(NSError **)outError; {
	return [self templateWithURL:url error:outError];
}
#pragma mark Properties
@dynamic allowedFileTypes;
- (NSArray *)allowedFileTypes {
	return [[self info] objectForKey:WCFileTemplateAllowedFileTypesInfoKey];
}

@end
