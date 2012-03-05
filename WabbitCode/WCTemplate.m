//
//  WCTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplate.h"
#import "NSURL+RSExtensions.h"

NSString *const WCTemplateInfoPlistName = @"templateInfo";
NSString *const WCTemplateInfoPlistExtension = @"plist";

NSString *const WCTemplateInfoSummaryKey = @"summary";
NSString *const WCTemplateInfoMainFileNameKey = @"mainFileName";
NSString *const WCTemplateInfoMainFileEncodingKey = @"mainFileEncoding";

@implementation WCTemplate
- (void)dealloc {
	[_name release];
	[_icon release];
	[_URL release];
	[_info release];
	[super dealloc];
}

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
	return [[self info] objectForKey:WCTemplateInfoMainFileNameKey];
}
@dynamic mainFileEncoding;
- (NSStringEncoding)mainFileEncoding {
	return [[[self info] objectForKey:WCTemplateInfoMainFileEncodingKey] unsignedIntegerValue];
}

@end
