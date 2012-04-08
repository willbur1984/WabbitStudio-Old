//
//  WCReallyAdvancedViewController.m
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCReallyAdvancedViewController.h"

NSString *const WCReallyAdvancedJumpBarSortItemsByKey = @"reallyAdvancedJumpBarSortItemsBy";
NSString *const WCReallyAdvancedJumpBarShowFileAndLineNumberKey = @"reallyAdvancedJumpBarShowFileAndLineNumber";

NSString *const WCReallyAdvancedJumpInFileSearchUsingCurrentEditorSelectionKey = @"reallyAdvancedJumpInFileSearchUsingCurrentEditorSelection";

NSString *const WCReallyAdvancedOpenQuicklySearchUsingCurrentEditorSelectionKey = @"reallyAdvancedOpenQuicklySearchUsingCurrentEditorSelection";

@implementation WCReallyAdvancedViewController
#pragma mark *** Subclass Overrides ***
- (id)init {
	return [super initWithNibName:[self nibName] bundle:nil];
}

- (NSString *)nibName {
	return @"WCReallyAdvancedView";
}
#pragma mark RSPreferencesModule
- (NSString *)identifier {
	return @"org.revsoft.wabbitcode.advanced.reallyadvanced";
}

- (NSString *)label {
	return NSLocalizedString(@"Really Advanced", @"Really Advanced");
}

- (NSImage *)image {
	return [NSImage imageNamed:@"ReallyAdvanced"];
}
#pragma mark RSUserDefaultsProvider
+ (NSDictionary *)userDefaults {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:WCReallyAdvancedJumpBarSortItemsByLocation],WCReallyAdvancedJumpBarSortItemsByKey,[NSNumber numberWithBool:YES],WCReallyAdvancedJumpBarShowFileAndLineNumberKey,[NSNumber numberWithBool:YES],WCReallyAdvancedJumpInFileSearchUsingCurrentEditorSelectionKey,[NSNumber numberWithBool:YES],WCReallyAdvancedOpenQuicklySearchUsingCurrentEditorSelectionKey, nil];
}
#pragma mark *** Public Methods ***
#pragma mark Properties
@synthesize initialFirstResponder=_initialFirstResponder;

@end
