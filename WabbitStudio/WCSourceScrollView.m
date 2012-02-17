//
//  WCSourceScrollView.m
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSourceScrollView.h"
#import "WCProjectDocument.h"
#import "WCBuildIssue.h"
#import "WCBuildController.h"
#import "WCSourceScroller.h"

@implementation WCSourceScrollView
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_delegate = nil;
	[super dealloc];
}

- (void)setDelegate:(id<WCSourceScrollViewDelegate>)delegate {
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCBuildControllerDidFinishBuildingNotification object:nil];
		[(WCSourceScroller *)[self verticalScroller] setScrollView:nil];
	}
	
	_delegate = delegate;
	
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:[[_delegate projectDocumentForSourceScrollView:self] buildController]];
		[(WCSourceScroller *)[self verticalScroller] setScrollView:self];
	}
}

@synthesize delegate=_delegate;

- (void)_buildControllerDidFinishBuilding:(NSNotification *)note {
	[(WCSourceScroller *)[self verticalScroller] setBuildIssues:[[self delegate] buildIssuesForSourceScrollView:self]];
}
@end
