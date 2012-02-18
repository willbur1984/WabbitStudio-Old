//
//  WCSourceScroller.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSScroller.h>

@interface WCSourceScroller : NSScroller {
	NSArray *_buildIssues;
	NSArray *_bookmarks;
}
@property (readwrite,retain,nonatomic) NSArray *buildIssues;
@property (readwrite,retain,nonatomic) NSArray *bookmarks;
@end
