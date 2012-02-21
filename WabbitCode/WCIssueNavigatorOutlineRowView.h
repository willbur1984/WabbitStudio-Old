//
//  WCIssueNavigatorOutlineRowView.h
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableRowView.h>

@interface WCIssueNavigatorOutlineRowView : NSTableRowView
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@end
