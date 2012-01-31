//
//  WCKeyBindingCommandSet.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandSet.h"
#import "WCKeyBindingCommandPair.h"
#import "RSDefines.h"
#import "WCKeyBindingCommandSetManager.h"

NSString *const WCKeyBindingCommandSetNameKey = @"name";
NSString *const WCKeyBindingCommandSetIdentifierKey = @"identifier";
NSString *const WCKeyBindingCommandSetKeyBindingsKey = @"keyBindings";

@interface WCKeyBindingCommandSet ()
- (void)_addKeyBindingCommandPairsFromMenu:(NSMenu *)menu toCommandPair:(WCKeyBindingCommandPair *)commandPair keyBindings:(NSDictionary *)keyBindings;
@end

@implementation WCKeyBindingCommandSet
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_name release];
	[_identifier release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"name: %@ identifier: %@",[self name],[self identifier]];
}
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
	WCKeyBindingCommandSet *copy = [super copyWithZone:zone];
	
	copy->_name = [_name copy];
	copy->_identifier = [_identifier copy];
	
	return copy;
}
#pragma mark NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
	WCKeyBindingCommandSet *copy = [super mutableCopyWithZone:zone];
	
	copy->_name = [[NSString alloc] initWithFormat:@"Copy of \"%@\"",_name];
	copy->_identifier = [[NSString alloc] initWithFormat:@"org.revsoft.wabbitstudio.keybindingcommandset.%@",copy->_name];
	
	return copy;
}
#pragma mark RSPlistArchiving
- (NSDictionary *)plistRepresentation {
	NSArray *pairs = [self flattenedCommandPairs];
	NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[plist setObject:[self name] forKey:WCKeyBindingCommandSetNameKey];
	[plist setObject:[self identifier] forKey:WCKeyBindingCommandSetIdentifierKey];
	
	NSMutableDictionary *keyBindings = [NSMutableDictionary dictionaryWithCapacity:[pairs count]];
	
	[pairs enumerateObjectsUsingBlock:^(id pair, NSUInteger idx, BOOL *stop) {
		NSString *actionName = NSStringFromSelector([[pair menuItem] action]);
		
		// the actionName has already been used by another command pair, add a sub dictionary uses the menu item's tag
		if ([keyBindings objectForKey:actionName]) {
			NSMutableDictionary *tags = [[keyBindings objectForKey:actionName] objectForKey:@"tags"];
			if (!tags) {
				WCKeyBindingCommandPair *oldPair = nil;
				for (WCKeyBindingCommandPair *rPair in [[pairs subarrayWithRange:NSMakeRange(0, idx)] reverseObjectEnumerator]) {
					if ([actionName isEqualToString:NSStringFromSelector([[rPair menuItem] action])]) {
						oldPair = rPair;
						break;
					}
				}
				
				tags = [NSMutableDictionary dictionaryWithObjectsAndKeys:[oldPair plistRepresentation],[NSString stringWithFormat:@"%ld",[[oldPair menuItem] tag]], nil];
				[keyBindings setObject:[NSDictionary dictionaryWithObjectsAndKeys:tags,@"tags", nil] forKey:actionName];
			}
			NSDictionary *pairPlist = [pair plistRepresentation];
			[tags setObject:pairPlist forKey:[NSString stringWithFormat:@"%ld",[[pair menuItem] tag]]];
		}
		else {
			NSDictionary *pairPlist = [pair plistRepresentation];
			[keyBindings setObject:pairPlist forKey:actionName];
		}
	}];
	
	[plist setObject:keyBindings forKey:WCKeyBindingCommandSetKeyBindingsKey];
	
	return [[plist copy] autorelease];
}

- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_name = [[plistRepresentation objectForKey:WCKeyBindingCommandSetNameKey] retain];
	_identifier = [[plistRepresentation objectForKey:WCKeyBindingCommandSetIdentifierKey] retain];
	
	NSDictionary *keyBindings = [plistRepresentation objectForKey:WCKeyBindingCommandSetKeyBindingsKey];
	
	for (NSMenuItem *item in [[[NSApplication sharedApplication] mainMenu] itemArray]) {
		WCKeyBindingCommandPair *pair = [WCKeyBindingCommandPair treeNodeWithRepresentedObject:item];
		
		[[self mutableChildNodes] addObject:pair];
		
		if ([item hasSubmenu])
			[self _addKeyBindingCommandPairsFromMenu:[item submenu] toCommandPair:pair keyBindings:keyBindings];
	}
	
	return self;
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@synthesize URL=_URL;
@synthesize name=_name;
@synthesize identifier=_identifier;
@dynamic commandPairs;
- (NSArray *)commandPairs {
	return [self childNodes];
}
@dynamic flattenedCommandPairs;
- (NSArray *)flattenedCommandPairs {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	for (WCKeyBindingCommandPair *pair in [self commandPairs])
		[retval addObjectsFromArray:[pair childNodes]];
	return [[retval copy] autorelease];
}
@dynamic customizedCommandPairs;
- (NSArray *)customizedCommandPairs {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	NSSet *defaultKeys = [[WCKeyBindingCommandSetManager sharedManager] defaultKeys];
	
	for (WCKeyBindingCommandPair *pair in [self flattenedCommandPairs]) {
		NSString *key = [pair key];
		if ([key length] && ![defaultKeys containsObject:key])
			[retval addObject:pair];
	}
	
	return [[retval copy] autorelease];
}
#pragma mark *** Private Methods ***
- (void)_addKeyBindingCommandPairsFromMenu:(NSMenu *)menu toCommandPair:(WCKeyBindingCommandPair *)commandPair keyBindings:(NSDictionary *)keyBindings; {
	for (NSMenuItem *item in [menu itemArray]) {
		NSString *actionName = NSStringFromSelector([item action]);
		NSDictionary *keyBindingDict = [keyBindings objectForKey:actionName];
		
		if (keyBindingDict) {
			KeyCombo combo = WCKeyBindingCommandPairEmptyKeyCombo();
			
			if ([keyBindingDict objectForKey:WCKeyBindingCommandPairTagsKey]) {
				if ([[keyBindingDict objectForKey:WCKeyBindingCommandPairTagsKey] objectForKey:[NSString stringWithFormat:@"%ld",[item tag]]])
					keyBindingDict = [[keyBindingDict objectForKey:WCKeyBindingCommandPairTagsKey] objectForKey:[NSString stringWithFormat:@"%ld",[item tag]]];
			}
			
			if ([keyBindingDict objectForKey:WCKeyBindingCommandPairKeyCodeKey])
				combo.code = [[keyBindingDict objectForKey:WCKeyBindingCommandPairKeyCodeKey] unsignedIntegerValue];
			if ([[[keyBindingDict objectForKey:WCKeyBindingCommandPairModifierFlagsKey] objectForKey:WCKeyBindingCommandPairCommandModifierMaskKey] boolValue])
				combo.flags |= NSCommandKeyMask;
			if ([[[keyBindingDict objectForKey:WCKeyBindingCommandPairModifierFlagsKey] objectForKey:WCKeyBindingCommandPairOptionModifierMaskKey] boolValue])
				combo.flags |= NSAlternateKeyMask;
			if ([[[keyBindingDict objectForKey:WCKeyBindingCommandPairModifierFlagsKey] objectForKey:WCKeyBindingCommandPairShiftModifierMaskKey] boolValue])
				combo.flags |= NSShiftKeyMask;
			if ([[[keyBindingDict objectForKey:WCKeyBindingCommandPairModifierFlagsKey] objectForKey:WCKeyBindingCommandPairControlModifierMaskKey] boolValue])
				combo.flags |= NSControlKeyMask;
			
			//if ([item isAlternate])
			//combo.flags |= NSAlternateKeyMask;
			
			WCKeyBindingCommandPair *pair = [WCKeyBindingCommandPair keyBindingCommandPairForAction:[item action] keyCombo:combo];
			[pair setRepresentedObject:item];
			
			[[commandPair mutableChildNodes] addObject:pair];
		}
		else if ([item hasSubmenu])			
			[self _addKeyBindingCommandPairsFromMenu:[item submenu] toCommandPair:commandPair keyBindings:keyBindings];
	}
}
@end
