//
//  WCIssueContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
	NSUInteger errorCount = 0, warningCount = 0;
	
	if ([[self representedObject] isKindOfClass:[WCProject class]]) {		
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
	}
	else {
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
	}
	
	NSString *errorString;
	if (errorCount > 1)
		errorString = [NSString stringWithFormat:NSLocalizedString(@"%lu errors", @"errors format string"),errorCount];
	else if (errorCount == 1)
		errorString = NSLocalizedString(@"1 error", @"1 error");
	else
		errorString = NSLocalizedString(@"0 errors", @"0 errors");
	
	NSString *warningString;
	if (warningCount > 1)
		warningString = [NSString stringWithFormat:NSLocalizedString(@"%lu warnings", @"warnings format string"),errorCount];
	else if (warningCount == 1)
		warningString = NSLocalizedString(@"1 warning", @"1 warning");
	else
		warningString = NSLocalizedString(@"0 warnings", @"0 warnings");
	
	if (errorCount && warningCount)
		return [NSString stringWithFormat:NSLocalizedString(@"%@, %@", @"errors and warnings format string"),errorString,warningString];
	else if (errorCount)
		return errorString;
	else
		return warningString;
}

@end
