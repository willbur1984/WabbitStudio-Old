//
//  WCTemplateCategory.m
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

#import "WCTemplateCategory.h"
#import "NSURL+RSExtensions.h"

@implementation WCTemplateCategory
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_icon release];
	[_URL release];
	[_name release];
	[super dealloc];
}
#pragma mark *** Public Methods ***
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
#pragma mark Properties
@synthesize URL=_URL;
@synthesize name=_name;
@synthesize icon=_icon;
@synthesize header=_header;

@end
