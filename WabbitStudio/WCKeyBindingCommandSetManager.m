//
//  WCKeyBindingCommandSetManager.m
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCKeyBindingCommandSetManager.h"
#import "WCKeyBindingCommandSet.h"

@implementation WCKeyBindingCommandSetManager
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	_commandSets = [[NSMutableArray alloc] initWithCapacity:0];
	[_commandSets addObject:[self defaultCommandSet]];
	
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
