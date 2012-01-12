//
//  WCKeyBindingCommandSet.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"
#import "RSPlistArchiving.h"

@interface WCKeyBindingCommandSet : RSTreeNode <RSPlistArchiving> {
	NSString *_name;
	NSString *_identifier;
}
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *identifer;
@property (readonly,nonatomic) NSArray *commandPairs;
@property (readonly,nonatomic) NSArray *flattenedCommandPairs;

@end
