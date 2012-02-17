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

- (NSAttributedString *)attributedToolTip {
	NSMutableAttributedString *retval;
	
	switch ([self type]) {
		case WCBuildIssueTypeError:
			retval = [[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"error: ", @"error: ") attributes:RSToolTipProviderDefaultAttributes()] autorelease];
			[retval applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [retval length])];
			[retval addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor],NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [retval length])];
			break;
		case WCBuildIssueTypeWarning:
			retval = [[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"warning: ", @"warning: ") attributes:RSToolTipProviderDefaultAttributes()] autorelease];
			[retval applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [retval length])];
			break;
		default:
			break;
	}
	
	[retval appendAttributedString:[[[NSAttributedString alloc] initWithString:[self message] attributes:RSToolTipProviderDefaultAttributes()] autorelease]];
	
	return retval;
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

+ (NSGradient *)errorFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor redColor] colorWithAlphaComponent:0.2] endingColor:[[NSColor redColor] colorWithAlphaComponent:0.45]];
	});
	return retval;
}
+ (NSGradient *)errorSelectedFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor redColor] colorWithAlphaComponent:0.05] endingColor:[[NSColor redColor] colorWithAlphaComponent:0.3]];
	});
	return retval;
}
+ (NSColor *)errorFillColor; {
	return [NSColor redColor];
}
+ (NSGradient *)warningFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.2] endingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.45]];
	});
	return retval;
}
+ (NSGradient *)warningSelectedFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.05] endingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.3]];
	});
	return retval;
}
+ (NSColor *)warningFillColor; {
	return [NSColor yellowColor];
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
