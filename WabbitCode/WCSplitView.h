//
//  WCSplitView.h
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSSplitView.h>

@interface WCSplitView : NSSplitView {
	NSColor *_dividerColor;
}
@property (readwrite,retain,nonatomic) NSColor *dividerColor;
@end
