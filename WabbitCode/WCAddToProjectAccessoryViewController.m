//
//  WCAddToProjectAccessoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/23/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCAddToProjectAccessoryViewController.h"

NSString *const WCAddToProjectDestinationCopyItemsKey = @"addToProjectDestinationCopyItems";
NSString *const WCAddToProjectFoldersCreationKey = @"addToProjectFoldersCreation";

@implementation WCAddToProjectAccessoryViewController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	
	return self;
}

- (NSString *)nibName {
	return @"WCAddToProjectAccessoryView";
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],WCAddToProjectDestinationCopyItemsKey,[NSNumber numberWithUnsignedInt:WCAddToProjectFoldersCreateGroups],WCAddToProjectFoldersCreationKey, nil];
}

@end
