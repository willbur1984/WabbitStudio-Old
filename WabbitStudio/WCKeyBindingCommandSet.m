//
//  WCKeyBindingCommandSet.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandSet.h"
#import "WCKeyBindingCommandPair.h"

static NSString *const WCKeyBindingCommandSetNameKey = @"name";
static NSString *const WCKeyBindingCommandSetIdentifierKey = @"identifier";
static NSString *const WCKeyBindingCommandSetKeyBindingsKey = @"keyBindings";

@interface WCKeyBindingCommandSet ()
- (void)_addKeyBindingCommandPairsFromMenu:(NSMenu *)menu toCommandPair:(WCKeyBindingCommandPair *)commandPair keyBindings:(NSDictionary *)keyBindings;
@end

@implementation WCKeyBindingCommandSet
- (void)dealloc {
	[_name release];
	[_identifier release];
	[super dealloc];
}

- (NSDictionary *)plistRepresentation {
	return nil;
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

@synthesize name=_name;
@synthesize identifer=_identifier;
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

- (void)_addKeyBindingCommandPairsFromMenu:(NSMenu *)menu toCommandPair:(WCKeyBindingCommandPair *)commandPair keyBindings:(NSDictionary *)keyBindings; {
	for (NSMenuItem *item in [menu itemArray]) {
		NSString *actionName = NSStringFromSelector([item action]);
		NSDictionary *keyBindingDict = [keyBindings objectForKey:actionName];
		if (keyBindingDict) {
			KeyCombo combo = WCKeyBindingCommandPairEmptyKeyCombo();
			if ([keyBindingDict objectForKey:@"keyCode"])
				combo.code = [[keyBindingDict objectForKey:@"keyCode"] unsignedIntegerValue];
			if ([[[keyBindingDict objectForKey:@"modifierFlags"] objectForKey:@"command"] boolValue])
				combo.flags |= NSCommandKeyMask;
			else if ([[[keyBindingDict objectForKey:@"modifierFlags"] objectForKey:@"option"] boolValue])
				combo.flags |= NSAlternateKeyMask;
			else if ([[[keyBindingDict objectForKey:@"modifierFlags"] objectForKey:@"shift"] boolValue])
				combo.flags |= NSShiftKeyMask;
			else if ([[[keyBindingDict objectForKey:@"modifierFlags"] objectForKey:@"control"] boolValue])
				combo.flags |= NSControlKeyMask;
			
			if ([item isAlternate])
				combo.flags |= NSAlternateKeyMask;
			
			WCKeyBindingCommandPair *pair = [WCKeyBindingCommandPair keyBindingCommandPairForAction:[item action] keyCombo:combo];
			[pair setRepresentedObject:item];
			
			[[commandPair mutableChildNodes] addObject:pair];
		}
		else if ([item hasSubmenu]) {
			WCKeyBindingCommandPair *pair = [WCKeyBindingCommandPair treeNodeWithRepresentedObject:item];
			
			[[commandPair mutableChildNodes] addObject:pair];
			
			[self _addKeyBindingCommandPairsFromMenu:[item submenu] toCommandPair:pair keyBindings:keyBindings];
		}
	}
}
@end
