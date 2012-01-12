//
//  WCKeyBindingCommandPair.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandPair.h"
#import "RSDefines.h"

@interface WCKeyBindingCommandPair ()
- (NSMenuItem *)_menuItemMatchingSelector:(SEL)action inMenu:(NSMenu *)menu;
@end

@implementation WCKeyBindingCommandPair

- (void)dealloc {
	[_menuItem release];
	[super dealloc];
}

- (id)initWithRepresentedObject:(id)representedObject {
	if (!(self = [super initWithRepresentedObject:representedObject]))
		return nil;
	
	_keyCombo = WCKeyBindingCommandPairEmptyKeyCombo();
	
	return self;
}

+ (WCKeyBindingCommandPair *)keyBindingCommandPairForAction:(SEL)action keyCombo:(KeyCombo)keyCombo; {
	return [[[[self class] alloc] initWithAction:action keyCombo:keyCombo] autorelease];
}
- (id)initWithAction:(SEL)action keyCombo:(KeyCombo)keyCombo; {
	if (!(self = [super init]))
		return nil;
	
	_action = action;
	_keyCombo = keyCombo;
	
	return self;
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
	if (_keyCombo.code == ShortcutRecorderEmptyCode && _keyCombo.flags == ShortcutRecorderEmptyFlags)
		return nil;
	return SRStringForCocoaModifierFlagsAndKeyCode(_keyCombo.flags, _keyCombo.code);
}

@dynamic menuItem;
- (NSMenuItem *)menuItem {
	if ([self representedObject])
		return [self representedObject];
	else if (!_menuItem) {
		_menuItem = [self _menuItemMatchingSelector:_action inMenu:[[NSApplication sharedApplication] mainMenu]];
	}
	return _menuItem;
}
@synthesize keyCombo=_keyCombo;

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
