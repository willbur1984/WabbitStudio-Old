//
//  WCBuildIssueContainer.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBuildIssueContainer.h"

@implementation WCBuildIssueContainer
+ (id)buildIssueContainerWithBuildIssue:(WCBuildIssue *)buildIssue; {
	return [[[[self class] alloc] initWithBuildIssue:buildIssue] autorelease];
}
- (id)initWithBuildIssue:(WCBuildIssue *)buildIssue; {
	if (!(self = [super initWithRepresentedObject:buildIssue]))
		return nil;
	
	return self;
}
@end
