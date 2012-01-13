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
@property (readwrite,copy,nonatomic) NSURL *URL;
@property (readwrite,copy,nonatomic) NSString *name;
@property (readwrite,copy,nonatomic) NSString *identifier;
@property (readonly,nonatomic) NSArray *commandPairs;
@property (readonly,nonatomic) NSArray *flattenedCommandPairs;
@property (readonly,nonatomic) NSArray *customizedCommandPairs;

@end
