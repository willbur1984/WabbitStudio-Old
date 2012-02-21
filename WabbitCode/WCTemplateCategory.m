//
//  WCTemplateCategory.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplateCategory.h"
#import "NSURL+RSExtensions.h"

@implementation WCTemplateCategory
- (void)dealloc {
	[_icon release];
	[_URL release];
	[_name release];
	[super dealloc];
}

+ (id)templateCategoryWithURL:(NSURL *)url header:(BOOL)header; {
	return [[[[self class] alloc] initWithURL:url header:header] autorelease];
}
- (id)initWithURL:(NSURL *)url header:(BOOL)header; {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_URL = [url copy];
	_name = [[url lastPathComponent] copy];
	_icon = [[NSImage imageNamed:NSImageNameFolder] retain];
	_header = header;
	
	return self;
}
+ (id)templateCategoryWithURL:(NSURL *)url; {
	return [[[[self class] alloc] initWithURL:url header:NO] autorelease];
}
- (id)initWithURL:(NSURL *)url; {
	return [self initWithURL:url header:NO];
}

@synthesize URL=_URL;
@synthesize name=_name;
@synthesize icon=_icon;
@synthesize header=_header;

@end
