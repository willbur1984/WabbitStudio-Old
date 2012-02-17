//
//  WCSymbolNavigatorOutlineRowView.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableRowView.h>

@interface WCSymbolNavigatorOutlineRowView : NSTableRowView
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@end
