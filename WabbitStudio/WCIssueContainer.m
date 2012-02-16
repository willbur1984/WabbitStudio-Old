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
#import "WCBuildIssueContainer.h"

@implementation WCIssueContainer
- (BOOL)isLeafNode {
	return NO;
}

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
		NSUInteger errorCount = 0, warningCount = 0;
		
		for (id object in [self childNodes]) {
			if ([object isKindOfClass:[WCIssueContainer class]]) {
				for (WCBuildIssueContainer *container in [object childNodes]) {
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
			}
			else
				errorCount++;
		}
		
		return [NSString stringWithFormat:NSLocalizedString(@"%lu error(s) total, %lu warning(s) total", @"issue container project status string format string"),errorCount,warningCount];
	}
	else {
		NSUInteger errorCount = 0, warningCount = 0;
		
		for (WCBuildIssueContainer *container in [self childNodes]) {
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
