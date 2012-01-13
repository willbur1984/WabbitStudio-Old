//
//  WCKeyBindingCommandSetManager.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandSetManager.h"
#import "WCKeyBindingCommandSet.h"
#import "WCKeyBindingCommandPair.h"
#import "WCMiscellaneousPerformer.h"
#import "WCKeyBindingsViewController.h"
#import "NSObject+WCExtensions.h"
#import "RSDefines.h"

@interface WCKeyBindingCommandSetManager ()
@property (readonly,nonatomic) NSMutableArray *mutableCommandSets;

- (void)_setupObservingForCommandSet:(WCKeyBindingCommandSet *)commandSet;
- (void)_cleanupObservingForCommandSet:(WCKeyBindingCommandSet *)commandSet;

- (void)_loadKeyBindingsFromCommandSet:(WCKeyBindingCommandSet *)commandSet;
@end

@implementation WCKeyBindingCommandSetManager
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_commandSets = [[NSMutableArray alloc] initWithCapacity:0];
	_userCommandSetIdentifiers = [[NSMutableSet alloc] initWithCapacity:0];
	_unsavedCommandSets = [[NSHashTable hashTableWithWeakObjects] retain];
	
	NSArray *userCommandSetIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:WCKeyBindingsUserCommandSetIdentifiersKey];
	
	// first load the user command sets
	for (NSURL *commandSetURL in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[WCMiscellaneousPerformer sharedPerformer] userKeyBindingCommandSetsDirectoryURL] includingPropertiesForKeys:[NSArray array] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL]) {
		
		WCKeyBindingCommandSet *commandSet = [[[WCKeyBindingCommandSet alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:commandSetURL]] autorelease];
		
		if ([self containsCommandSet:commandSet])
			continue;
		else if (![userCommandSetIdentifiers containsObject:[commandSet identifier]])
			continue;
		
		[[self mutableCommandSets] addObject:commandSet];
	}
	
	// only load the default command sets if no user command sets were loaded
	if (![[self commandSets] count]) {
		for (WCKeyBindingCommandSet *commandSet in [self defaultCommandSets]) {
			if (![self containsCommandSet:commandSet])
				[[self mutableCommandSets] addObject:[[commandSet copy] autorelease]];
		}
	}
	
	NSString *currentIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:WCKeyBindingsCurrentCommandSetIdentifierKey];
	
	// look for a command set matching the current identifier
	for (WCKeyBindingCommandSet *commandSet in [self commandSets]) {
		if ([[commandSet identifier] isEqualToString:currentIdentifier]) {
			_currentCommandSet = [commandSet retain];
			break;
		}
	}
	
	// otherwise use the first command set
	if (!_currentCommandSet)
		_currentCommandSet = [[[self commandSets] objectAtIndex:0] retain];
	
	// start observing our current command set for changes
	[self _setupObservingForCommandSet:_currentCommandSet];
	
	// update the current identifier
	[[NSUserDefaults standardUserDefaults] setObject:[_currentCommandSet identifier] forKey:WCKeyBindingsCurrentCommandSetIdentifierKey];
	
	// sort the command sets by name
	[_commandSets sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:WCKeyBindingCommandSetNameKey ascending:YES selector:@selector(localizedStandardCompare:)]]];
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:WCKeyBindingCommandSetNameKey]) {
		[(WCKeyBindingCommandSet *)object setIdentifier:[NSString stringWithFormat:@"org.revsoft.wabbitstudio.keybindingcommandset.%@",[object name]]];
		
		[[NSUserDefaults standardUserDefaults] setObject:[object identifier] forKey:WCKeyBindingsCurrentCommandSetIdentifierKey];
		
		[_unsavedCommandSets addObject:_currentCommandSet];
		[_userCommandSetIdentifiers setSet:[NSSet setWithArray:[[self commandSets] valueForKeyPath:@"identifier"]]];
	}
	else if ([keyPath isEqualToString:WCKeyBindingCommandPairKeyCodeKey])
		[_unsavedCommandSets addObject:[object commandSet]];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

+ (WCKeyBindingCommandSetManager *)sharedManager; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (BOOL)containsCommandSet:(WCKeyBindingCommandSet *)commandSet {
	for (WCKeyBindingCommandSet *cmpSet in [self commandSets]) {
		if ([[cmpSet identifier] isEqualToString:[commandSet identifier]])
			return YES;
	}
	return NO;
}

- (BOOL)saveCurrentCommandSets:(NSError **)outError {
	NSURL *directoryURL = [[WCMiscellaneousPerformer sharedPerformer] userKeyBindingCommandSetsDirectoryURL];
	for (WCKeyBindingCommandSet *commandSet in [[_unsavedCommandSets copy] autorelease]) {
		NSData *data = [NSPropertyListSerialization dataWithPropertyList:[commandSet plistRepresentation] format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
		
		if (!data) {
			// TODO: construct an appropriate error
			if (outError) {
				
			}
			return NO;
		}
		else {
			NSURL *themeURL = [[directoryURL URLByAppendingPathComponent:[commandSet name]] URLByAppendingPathExtension:@"plist"];
			
			if (![data writeToURL:themeURL options:NSDataWritingAtomic error:outError])
				return NO;
			
			[commandSet setURL:themeURL];
		}
		
		[_unsavedCommandSets removeObject:commandSet];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[_userCommandSetIdentifiers allObjects] forKey:WCKeyBindingsUserCommandSetIdentifiersKey];
	
	return YES;
}

- (void)loadKeyBindingsFromCurrentCommandSet; {
	[self _loadKeyBindingsFromCommandSet:[self currentCommandSet]];
}

- (NSString *)defaultKeyForMenuItem:(NSMenuItem *)menuItem; {
	static NSDictionary *actionNamesToCommandPairs;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:[[[self defaultCommandSet] flattenedCommandPairs] count]];
		NSArray *pairs = [[self defaultCommandSet] flattenedCommandPairs];
		
		[pairs enumerateObjectsUsingBlock:^(WCKeyBindingCommandPair *pair, NSUInteger idx, BOOL *stop) {
			NSString *actionName = NSStringFromSelector([[pair menuItem] action]);
			
			if ([temp objectForKey:actionName]) {
				[temp setObject:[NSNull null] forKey:actionName];				
				[temp setObject:pair forKey:[NSString stringWithFormat:@"%@%ld",actionName,[[pair menuItem] tag]]];
			}
			else {
				[temp setObject:pair forKey:actionName];
			}
		}];
		
		actionNamesToCommandPairs = [temp copy];
	});
	
	NSString *actionName = NSStringFromSelector([menuItem action]);
	id value = [actionNamesToCommandPairs objectForKey:actionName];
	if ([value respondsToSelector:@selector(key)])
		return [value key];
	return [[actionNamesToCommandPairs objectForKey:[NSString stringWithFormat:@"%@%ld",actionName,[menuItem tag]]] key];
}

@synthesize commandSets=_commandSets;
@dynamic mutableCommandSets;
- (NSMutableArray *)mutableCommandSets {
	return [self mutableArrayValueForKey:@"commandSets"];
}
- (NSUInteger)countOfCommandSets {
	return [_commandSets count];
}
- (id)objectInCommandSetsAtIndex:(NSUInteger)index {
	return [_commandSets objectAtIndex:index];
}
- (void)insertObject:(WCKeyBindingCommandSet *)object inCommandSetsAtIndex:(NSUInteger)index {
	[_unsavedCommandSets addObject:object];
	[_userCommandSetIdentifiers addObject:[object identifier]];
	[_commandSets insertObject:object atIndex:index];
}
- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index {
	WCKeyBindingCommandSet *commandSet = [_commandSets objectAtIndex:index];
	
	if ([commandSet URL])
		[[NSWorkspace sharedWorkspace] recycleURLs:[NSArray arrayWithObject:[commandSet URL]] completionHandler:NULL];
	
	[_unsavedCommandSets removeObject:commandSet];
	[_userCommandSetIdentifiers removeObject:[commandSet identifier]];
	[_commandSets removeObjectAtIndex:index];
}

@dynamic defaultCommandSets;
- (NSArray *)defaultCommandSets {
	static NSArray *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSArray alloc] initWithObjects:[[[WCKeyBindingCommandSet alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"DefaultKeyBindings" withExtension:@"plist"]]] autorelease], nil];
	});
	return retval;
}
@dynamic defaultCommandSet;
- (WCKeyBindingCommandSet *)defaultCommandSet {
	static WCKeyBindingCommandSet *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[[self defaultCommandSets] objectAtIndex:0] retain];
	});
	return retval;
}
@dynamic defaultKeys;
- (NSSet *)defaultKeys {
	static NSSet *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSArray *pairs = [[self defaultCommandSet] flattenedCommandPairs];
		NSMutableSet *temp = [NSMutableSet setWithCapacity:[pairs count]];
		
		for (WCKeyBindingCommandPair *pair in pairs) {
			NSString *key = [pair key];
			if ([key length])
				[temp addObject:key];
		}
		
		retval = [temp copy];
	});
	return retval;
}
@dynamic currentCommandSet;
- (WCKeyBindingCommandSet *)currentCommandSet {
	return _currentCommandSet;
}
- (void)setCurrentCommandSet:(WCKeyBindingCommandSet *)currentCommandSet {
	if (_currentCommandSet == currentCommandSet)
		return;
	
	[self _cleanupObservingForCommandSet:_currentCommandSet];
	
	[_currentCommandSet release];
	_currentCommandSet = [currentCommandSet retain];
	
	[self _setupObservingForCommandSet:_currentCommandSet];
	
	[[NSUserDefaults standardUserDefaults] setObject:[_currentCommandSet identifier] forKey:WCKeyBindingsCurrentCommandSetIdentifierKey];
	
	[self _loadKeyBindingsFromCommandSet:_currentCommandSet];
}

- (void)_setupObservingForCommandSet:(WCKeyBindingCommandSet *)commandSet; {
	[commandSet addObserver:self forKeyPaths:[NSSet setWithObjects:@"name", nil]];
	
	for (WCKeyBindingCommandPair *pair in [commandSet flattenedCommandPairs])
		[pair addObserver:self forKeyPaths:[NSSet setWithObjects:@"keyCode",nil]];
}
- (void)_cleanupObservingForCommandSet:(WCKeyBindingCommandSet *)commandSet; {
	[commandSet removeObserver:self forKeyPaths:[NSSet setWithObjects:@"name", nil]];
	
	for (WCKeyBindingCommandPair *pair in [commandSet flattenedCommandPairs])
		[pair removeObserver:self forKeyPaths:[NSSet setWithObjects:@"keyCode", nil]];
}

- (void)_loadKeyBindingsFromCommandSet:(WCKeyBindingCommandSet *)commandSet; {
	for (WCKeyBindingCommandPair *pair in [commandSet flattenedCommandPairs]) {
		KeyCombo combo = [pair keyCombo];
		if (combo.code == ShortcutRecorderEmptyCode && combo.flags == ShortcutRecorderEmptyFlags)
			continue;
		
		[pair updateMenuItemWithCurrentKeyCode];
	}
}
@end
