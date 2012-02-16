//
//  WCIssueContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCIssueContainer.h"
#import "WCBuildIssue.h"
#import "WCProject.h"

@implementation WCIssueContainer
+ (id)issueContainerWithFile:(WCFile *)file; {
	return [[(WCIssueContainer *)[[self class] alloc] initWithFile:file] autorelease];
}
- (id)initWithFile:(WCFile *)file; {
	if (!(self = [super initWithRepresentedObject:file]))
		return nil;
	
	return self;
}

@dynamic statusString;
- (NSString *)statusString {
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {
		return nil;
	}
	else {
		NSUInteger errorCount = 0, warningCount = 0;
		
		for (WCIssueContainer *container in [self childNodes]) {
			WCBuildIssueType type = [(WCBuildIssue *)[container representedObject] type];
			
			switch (type) {
				case WCBuildIssueTypeError:
					errorCount++;
					break;
				case WCBuildIssueTypeWarning:
					warningCount++;
					break;
				default:
					break;
			}
		}
		
		return [NSString stringWithFormat:NSLocalizedString(@"%lu error(s), %lu warning(s)", @"issue container status string format string"),errorCount,warningCount];
	}
}

@end
