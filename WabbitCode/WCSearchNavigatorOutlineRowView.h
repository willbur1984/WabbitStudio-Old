//
//  WCSearchNavigatorOutlineRowView.h
//  WabbitStudio
//
//  Created by William Towe on 7/26/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableRowView.h>

@interface WCSearchNavigatorOutlineRowView : NSTableRowView
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@end
