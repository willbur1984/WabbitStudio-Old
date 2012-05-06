//
//  WCBuildIssue.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
			retval = nil;
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
	_buildIssueFlags.visible = YES;
	
	return self;
}

+ (NSGradient *)errorFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor redColor] colorWithAlphaComponent:0.15] endingColor:[[NSColor redColor] colorWithAlphaComponent:0.4]];
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
		retval = [[NSGradient alloc] initWithStartingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.15] endingColor:[[NSColor yellowColor] colorWithAlphaComponent:0.4]];
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
@dynamic visible;
- (BOOL)isVisible {
	return _buildIssueFlags.visible;
}
- (void)setVisible:(BOOL)visible {
	_buildIssueFlags.visible = visible;
}

@end
