//
//  WCTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTemplate.h"
#import "NSURL+RSExtensions.h"

NSString *const WCTemplateInfoPlistName = @"templateInfo";
NSString *const WCTemplateInfoPlistExtension = @"plist";

NSString *const WCTemplateInfoSummaryKey = @"summary";
NSString *const WCTemplateInfoMainFileNameKey = @"mainFileName";
NSString *const WCTemplateInfoMainFileEncodingKey = @"mainFileEncoding";

@implementation WCTemplate
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[_icon release];
	[_URL release];
	[_info release];
	[super dealloc];
}
#pragma mark *** Public Methods ***
+ (id)templateWithURL:(NSURL *)url error:(NSError **)outError; {
	return [[[[self class] alloc] initWithURL:url error:outError] autorelease];
}
- (id)initWithURL:(NSURL *)url error:(NSError **)outError; {
	if (!(self = [super init]))
		return nil;
	
	if (![url isDirectory]) {
		[self release];
		return nil;
	}
	
	NSURL *infoURL = [url URLByAppendingPathComponent:[WCTemplateInfoPlistName stringByAppendingPathExtension:WCTemplateInfoPlistExtension]];
	
	if (![infoURL checkResourceIsReachableAndReturnError:outError]) {
		[self release];
		return nil;
	}
	
	_URL = [infoURL copy];
	_name = [[[infoURL parentDirectoryURL] lastPathComponent] copy];
	
	NSDictionary *templateInfo = [NSDictionary dictionaryWithContentsOfURL:infoURL];
	
	_info = [templateInfo retain];
	
	return self;
}
#pragma mark Properties
@synthesize URL=_URL;
@synthesize info=_info;
@synthesize icon=_icon;
@synthesize name=_name;
@dynamic summary;
- (NSString *)summary {
	return [[self info] objectForKey:WCTemplateInfoSummaryKey];
}
@dynamic mainFileName;
- (NSString *)mainFileName {
	if ([[[self info] objectForKey:WCTemplateInfoMainFileNameKey] length])
		return [[self info] objectForKey:WCTemplateInfoMainFileNameKey];
	return NSLocalizedString(@"main.z80", @"main.z80");
}
@dynamic mainFileEncoding;
- (NSStringEncoding)mainFileEncoding {
	return [[[self info] objectForKey:WCTemplateInfoMainFileEncodingKey] unsignedIntegerValue];
}

@end
