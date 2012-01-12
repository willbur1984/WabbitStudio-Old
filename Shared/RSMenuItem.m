//
//  RSMenuItem.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSMenuItem.h"

@interface RSMenuItem ()
- (void)_privateInit;
@end

@implementation RSMenuItem
- (id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode {
	if (!(self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode]))
		return nil;
	
	[self _privateInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _privateInit];
	
	return self;
}

- (void)_privateInit; {
	// explicitly set the modifier mask to include the shift mask
	// for some reason, menu items set with shift as a modifier mask in Xcode don't report the shift mask as part of their key
	// equivalent mask, so SRRecorderControl doesn't work correctly when checking for key equivalent duplicates
	if ([[self keyEquivalent] length] == 1 && [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[[self keyEquivalent] characterAtIndex:0]])
		[self setKeyEquivalentModifierMask:([self keyEquivalentModifierMask]|NSShiftKeyMask)];
}
@end
