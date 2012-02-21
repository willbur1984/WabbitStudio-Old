//
//  WCKeyBindingCommandSetManager.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCKeyBindingCommandSet,WCKeyBindingCommandPair;

@interface WCKeyBindingCommandSetManager : NSObject {
	NSMutableArray *_commandSets;
	WCKeyBindingCommandSet *_currentCommandSet;
	NSMutableSet *_userCommandSetIdentifiers;
	NSHashTable *_unsavedCommandSets;
}
@property (readonly,nonatomic) NSArray *commandSets;
@property (readonly,nonatomic) NSArray *defaultCommandSets;
@property (readwrite,retain,nonatomic) WCKeyBindingCommandSet *currentCommandSet;
@property (readonly,nonatomic) WCKeyBindingCommandSet *defaultCommandSet;
@property (readonly,nonatomic) NSSet *defaultKeys;

+ (WCKeyBindingCommandSetManager *)sharedManager;

- (BOOL)containsCommandSet:(WCKeyBindingCommandSet *)commandSet;
- (BOOL)saveCurrentCommandSets:(NSError **)outError;

- (void)loadKeyBindingsFromCurrentCommandSet;

- (WCKeyBindingCommandPair *)defaultCommandPairForMenuItem:(NSMenuItem *)menuItem;
- (NSString *)defaultKeyForMenuItem:(NSMenuItem *)menuItem;
@end
