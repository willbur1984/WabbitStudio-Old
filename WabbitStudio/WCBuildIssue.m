//
//  WCBuildIssue.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildIssue.h"

@implementation WCBuildIssue
- (void)dealloc {
	[_message release];
	[_code release];
	[super dealloc];
}

+ (id)buildIssueOfType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code; {
	return [[[[self class] alloc] initWithType:type range:range message:message code:code] autorelease];
}
- (id)initWithType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code; {
	if (!(self = [super init]))
		return nil;
	
	_type = type;
	_range = range;
	_message = [message copy];
	_code = [code copy];
	
	return self;
}

@synthesize type=_type;
@synthesize range=_range;
@synthesize message=_message;
@synthesize code=_code;
@dynamic icon;
- (NSImage *)icon {
	switch ([self type]) {
		case WCBuildIssueTypeError:
			return [NSImage imageNamed:@"Error"];
		case WCBuildIssueTypeWarning:
			return [NSImage imageNamed:@"Warning"];
		default:
			return nil;
	}
}

@end
