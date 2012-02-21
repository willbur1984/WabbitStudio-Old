//
//  WCAddToProjectAccessoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCAddToProjectAccessoryViewController.h"

NSString *const WCAddToProjectDestinationCopyItemsKey = @"addToProjectDestinationCopyItems";
NSString *const WCAddToProjectFoldersCreationKey = @"addToProjectFoldersCreation";

@implementation WCAddToProjectAccessoryViewController

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	
	return self;
}

- (NSString *)nibName {
	return @"WCAddToProjectAccessoryView";
}

+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCAddToProjectDestinationCopyItemsKey,[NSNumber numberWithUnsignedInt:WCAddToProjectFoldersCreateGroups],WCAddToProjectFoldersCreationKey, nil];
}

@end
