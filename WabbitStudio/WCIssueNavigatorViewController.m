//
//  WCIssueNavigatorViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCIssueNavigatorViewController.h"
#import "WCProjectDocument.h"
#import "WCIssueContainer.h"
#import "WCBuildIssue.h"
#import "WCBuildIssueContainer.h"
#import "WCProjectContainer.h"
#import "WCProject.h"

@implementation WCIssueNavigatorViewController
- (void)dealloc {
	_projectDocument = nil;
	[_issueContainer release];
	[super dealloc];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_projectDocument = projectDocument;
	_issueContainer = [[WCIssueContainer alloc] initWithFile:[[projectDocument projectContainer] project]];
	
	return self;
}

@synthesize projectDocument=_projectDocument;
@synthesize issueContainer=_issueContainer;

@end
