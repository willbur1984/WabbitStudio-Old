//
//  WCKeyBindingCommandSet.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"
#import "RSPlistArchiving.h"

extern NSString *const WCKeyBindingCommandSetNameKey;
extern NSString *const WCKeyBindingCommandSetIdentifierKey;
extern NSString *const WCKeyBindingCommandSetKeyBindingsKey;

@interface WCKeyBindingCommandSet : RSTreeNode <RSPlistArchiving,NSCopying,NSMutableCopying> {
	NSURL *_URL;
	NSString *_name;
	NSString *_identifier;
}
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *identifer;
@property (readonly,nonatomic) NSArray *commandPairs;
@property (readonly,nonatomic) NSArray *flattenedCommandPairs;
@property (readwrite,copy,nonatomic) NSURL *URL;

@end
