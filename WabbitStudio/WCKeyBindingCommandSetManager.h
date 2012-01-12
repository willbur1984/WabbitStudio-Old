//
//  WCKeyBindingCommandSetManager.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCKeyBindingCommandSet;

@interface WCKeyBindingCommandSetManager : NSObject {
	NSMutableArray *_commandSets;
}
@property (readonly,nonatomic) NSArray *commandSets;
@property (readonly,nonatomic) WCKeyBindingCommandSet *defaultCommandSet;

+ (WCKeyBindingCommandSetManager *)sharedManager;
@end
