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
}
@property (readwrite,assign,nonatomic) IBOutlet NSScrollView *scrollView;

@property (readwrite,copy,nonatomic) NSArray *buildIssues;
@end
