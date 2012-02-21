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
#import "WCSourceTextStorage.h"

@implementation WCSourceScrollView
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_delegate = nil;
	[super dealloc];
}

- (void)setDelegate:(id<WCSourceScrollViewDelegate>)delegate {
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCBuildControllerDidFinishBuildingNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCSourceTextStorageDidAddBookmarkNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCSourceTextStorageDidRemoveBookmarkNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCSourceTextStorageDidRemoveAllBookmarksNotification object:nil];
	}
	
	_delegate = delegate;
	
	if (_delegate) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_buildControllerDidFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:[[_delegate projectDocumentForSourceScrollView:self] buildController]];
		
		[(WCSourceScroller *)[self verticalScroller] setBuildIssues:[[self delegate] buildIssuesForSourceScrollView:self]];
		
		WCSourceTextStorage *textStorage = [[self delegate] sourceTextStorageForSourceScrollView:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidAddBookmark:) name:WCSourceTextStorageDidAddBookmarkNotification object:textStorage];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveBookmark:) name:WCSourceTextStorageDidRemoveBookmarkNotification object:textStorage];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidRemoveAllBookmarks:) name:WCSourceTextStorageDidRemoveAllBookmarksNotification object:textStorage];
	}
}

@synthesize delegate=_delegate;

- (void)_buildControllerDidFinishBuilding:(NSNotification *)note {
	[(WCSourceScroller *)[self verticalScroller] setBuildIssues:[[self delegate] buildIssuesForSourceScrollView:self]];
}
- (void)_textStorageDidAddBookmark:(NSNotification *)note {
	[(WCSourceScroller *)[self verticalScroller] setBookmarks:[[[self delegate] sourceTextStorageForSourceScrollView:self] bookmarks]];
}
- (void)_textStorageDidRemoveBookmark:(NSNotification *)note {
	[(WCSourceScroller *)[self verticalScroller] setBookmarks:[[[self delegate] sourceTextStorageForSourceScrollView:self] bookmarks]];
}
- (void)_textStorageDidRemoveAllBookmarks:(NSNotification *)note {
	[(WCSourceScroller *)[self verticalScroller] setBookmarks:nil];
}
@end
