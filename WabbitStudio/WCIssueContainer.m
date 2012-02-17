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
		
		if (errorCount && warningCount) {
			if (errorCount == 1 && warningCount == 1)
				return NSLocalizedString(@"1 error total, 1 warning total", @"1 error total, 1 warning total");
			else if (errorCount == 1)
				return [NSString stringWithFormat:NSLocalizedString(@"1 error total, %lu warnings total", @"1 error multiple warnings format string"),warningCount];
			else if (warningCount == 1)
				return [NSString stringWithFormat:NSLocalizedString(@"%lu errors total, 1 warning total", @"multiple errors 1 warning format string"),errorCount];
			else
				return [NSString stringWithFormat:NSLocalizedString(@"%lu errors total, %lu warnings total", @"multiple errors multiple warnings"),errorCount,warningCount];				
		}
		return [NSString stringWithFormat:NSLocalizedString(@"%lu errors total, %lu warnings total", @"multiple errors multiple warnings"),errorCount,warningCount];
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
