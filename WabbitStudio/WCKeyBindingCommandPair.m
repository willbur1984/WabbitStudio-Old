//
//  WCKeyBindingCommandPair.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandPair.h"
#import "WCKeyBindingCommandSet.h"
#import "RSDefines.h"

NSString *const WCKeyBindingCommandPairKeyCodeKey = @"keyCode";
NSString *const WCKeyBindingCommandPairModifierFlagsKey = @"modifierFlags";
NSString *const WCKeyBindingCommandPairTagsKey = @"tags";
NSString *const WCKeyBindingCommandPairCommandModifierMaskKey = @"command";
NSString *const WCKeyBindingCommandPairOptionModifierMaskKey = @"option";
NSString *const WCKeyBindingCommandPairControlModifierMaskKey = @"control";
NSString *const WCKeyBindingCommandPairShiftModifierMaskKey = @"shift";

@interface WCKeyBindingCommandPair ()
- (NSMenuItem *)_menuItemMatchingSelector:(SEL)action inMenu:(NSMenu *)menu;
@end

@implementation WCKeyBindingCommandPair

- (id)initWithRepresentedObject:(id)representedObject {
	if (!(self = [super initWithRepresentedObject:representedObject]))
		return nil;
	
	_keyCombo = WCKeyBindingCommandPairEmptyKeyCombo();
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	WCKeyBindingCommandPair *copy = [super copyWithZone:zone];
	
	copy->_action = _action;
	copy->_keyCombo = _keyCombo;
	
	return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	WCKeyBindingCommandPair *copy = [super mutableCopyWithZone:zone];
	
	copy->_action = _action;
	copy->_keyCombo = _keyCombo;
	
	return copy;
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[plist setObject:[NSNumber numberWithInteger:_keyCombo.code] forKey:WCKeyBindingCommandPairKeyCodeKey];
	
	NSMutableDictionary *modifiers = [NSMutableDictionary dictionaryWithCapacity:0];
	if ((_keyCombo.flags & NSCommandKeyMask))
		[modifiers setObject:[NSNumber numberWithBool:YES] forKey:WCKeyBindingCommandPairCommandModifierMaskKey];
	if ((_keyCombo.flags & NSAlternateKeyMask))
		[modifiers setObject:[NSNumber numberWithBool:YES] forKey:WCKeyBindingCommandPairOptionModifierMaskKey];
	if ((_keyCombo.flags & NSControlKeyMask))
		[modifiers setObject:[NSNumber numberWithBool:YES] forKey:WCKeyBindingCommandPairControlModifierMaskKey];
	if ((_keyCombo.flags & NSShiftKeyMask))
		[modifiers setObject:[NSNumber numberWithBool:YES] forKey:WCKeyBindingCommandPairShiftModifierMaskKey];
	
	if ([modifiers count])
		[plist setObject:modifiers forKey:WCKeyBindingCommandPairModifierFlagsKey];
	
	return [[plist copy] autorelease];
}

+ (WCKeyBindingCommandPair *)keyBindingCommandPairForAction:(SEL)action keyCombo:(KeyCombo)keyCombo; {
	return [[[[self class] alloc] initWithAction:action keyCombo:keyCombo] autorelease];
}
- (id)initWithAction:(SEL)action keyCombo:(KeyCombo)keyCombo; {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_action = action;
	_keyCombo = keyCombo;
	
	return self;
}

- (void)updateMenuItemWithCurrentKeyCode; {
	if (WCKeyBindingCommandPairIsEmptyKeyCombo(_keyCombo)) {
		[[self menuItem] setKeyEquivalent:@""];
		[[self menuItem] setKeyEquivalentModifierMask:0];
		return;
	}
	
	[[self menuItem] setKeyEquivalent:SRCharacterForKeyCodeAndCocoaFlags(_keyCombo.code, _keyCombo.flags)];
	[[self menuItem] setKeyEquivalentModifierMask:_keyCombo.flags];
}

@dynamic name;
- (NSString *)name {
	if ([[self menuItem] isAlternate])
		return [NSString stringWithFormat:@"\t%@",[[self menuItem] title]];
	else if ([[self menuItem] menu] == [[NSApplication sharedApplication] mainMenu] ||
		[[[self menuItem] parentItem] menu] == [[NSApplication sharedApplication] mainMenu])
		return [[self menuItem] title];
	else if ([[self menuItem] menu] == [[[self menuItem] parentItem] submenu])
		return [NSString stringWithFormat:@"%@ \u2192 %@",[[[self menuItem] parentItem] title],[[self menuItem] title]];
	return [[self menuItem] title];
}
@dynamic key;
- (NSString *)key {
	if (WCKeyBindingCommandPairIsEmptyKeyCombo(_keyCombo))
		return nil;
	return SRStringForCocoaModifierFlagsAndKeyCode(_keyCombo.flags, _keyCombo.code);
}
+ (NSSet *)keyPathsForValuesAffectingKey {
	return [NSSet setWithObjects:@"keyCombo", nil];
}

@dynamic menuItem;
- (NSMenuItem *)menuItem {
	if (![self representedObject]) {
		[self setRepresentedObject:[self _menuItemMatchingSelector:_action inMenu:[[NSApplication sharedApplication] mainMenu]]];
	}
	return [self representedObject];
}
@dynamic keyCombo;
- (KeyCombo)keyCombo {
	return _keyCombo;
}
- (void)setKeyCombo:(KeyCombo)keyCombo {
	if (_keyCombo.code == keyCombo.code && _keyCombo.flags == keyCombo.flags)
		return;
	
	_keyCombo = keyCombo;
	
	[self updateMenuItemWithCurrentKeyCode];
}
@dynamic commandSet;
- (WCKeyBindingCommandSet *)commandSet {
	if ([[self parentNode] isKindOfClass:[WCKeyBindingCommandSet class]])
		return [self parentNode];
	return [[self parentNode] commandSet];
}

- (NSMenuItem *)_menuItemMatchingSelector:(SEL)action inMenu:(NSMenu *)menu; {
	NSMenuItem *retval = nil;
	for (NSMenuItem *item in [menu itemArray]) {
		if ([item action] == action) {
			retval = item;
			break;
		}
		else if ([item hasSubmenu] && (retval = [self _menuItemMatchingSelector:action inMenu:[item submenu]]))
			break;
	}
	return retval;
}

@end
