//
//  WCKeyBindingCommandSetManager.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandSetManager.h"
#import "WCKeyBindingCommandSet.h"
#import "WCMiscellaneousPerformer.h"
#import "WCKeyBindingsViewController.h"

@implementation WCKeyBindingCommandSetManager
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_commandSets = [[NSMutableArray alloc] initWithCapacity:0];
	_userCommandSetIdentifiers = [[NSMutableSet alloc] initWithCapacity:0];
	_unsavedCommandSets = [[NSHashTable hashTableWithWeakObjects] retain];
	
	[_commandSets addObject:[[[self defaultCommandSet] copy] autorelease]];
	[_unsavedCommandSets addObject:[_commandSets lastObject]];
	
	return self;
}

+ (WCKeyBindingCommandSetManager *)sharedManager; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
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

@synthesize commandSets=_commandSets;
@dynamic defaultCommandSet;
- (WCKeyBindingCommandSet *)defaultCommandSet {
	static WCKeyBindingCommandSet *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[WCKeyBindingCommandSet alloc] initWithPlistRepresentation:[NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"DefaultKeyBindings" withExtension:@"plist"]]];
	});
	return retval;
}

@end
