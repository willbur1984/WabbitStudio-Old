//
//  WCBreakpointNavigatorOutlineRowView.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableRowView.h>

@interface WCBreakpointNavigatorOutlineRowView : NSTableRowView
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@end
