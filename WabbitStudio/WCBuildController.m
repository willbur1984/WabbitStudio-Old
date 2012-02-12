//
//  WCBuildController.m
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildController.h"
#import "WCProjectDocument.h"
#import "WCBuildTarget.h"
#import "RSDefines.h"
#import "NSAlert-OAExtensions.h"

@implementation WCBuildController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[super dealloc];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

- (void)build; {
	if (![[[self projectDocument] buildTargets] count]) {
		NSString *message = NSLocalizedString(@"No Build Targets", @"No Build Targets");
		NSString *informative = NSLocalizedString(@"Your project does not have any build targets. Would you like to edit your build targets now?", @"no build targets alert informative string");
		NSAlert *noBuildTargetsAlert = [NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"Edit Build Targets\u2026", @"Edit Build Targets with ellipsis") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
		
		[noBuildTargetsAlert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self projectDocument] manageBuildTargets:nil];
		}];
		return;
	}
	
	WCBuildTarget *activeBuildTarget = [[self projectDocument] activeBuildTarget];
	
	if (!activeBuildTarget) {
		NSString *message = NSLocalizedString(@"No Active Build Target", @"No Active Build Target");
		NSString *informative = NSLocalizedString(@"Your project does not have an active build target. Would you like to assign an active build target now?", @"no active build target alert informative string");
		NSAlert *noActiveBuildTargetAlert = [NSAlert alertWithMessageText:message defaultButton:NSLocalizedString(@"Assign Active Build Target\u2026", @"Assign Active Build Target with ellipsis") alternateButton:LOCALIZED_STRING_CANCEL otherButton:nil informativeTextWithFormat:informative];
		
		[noActiveBuildTargetAlert beginSheetModalForWindow:[[self projectDocument] windowForSheet] completionHandler:^(NSAlert *alert, NSInteger returnCode) {
			[[alert window] orderOut:nil];
			if (returnCode == NSAlertAlternateReturn)
				return;
			
			[[self projectDocument] manageBuildTargets:nil];
		}];
		return;
	}
}
- (void)buildAndRun; {
	
}

@synthesize projectDocument=_projectDocument;

@end
