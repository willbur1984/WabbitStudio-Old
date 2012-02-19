//
//  WCEditBreakpointViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>

@class WCBreakpoint,RSHexadecimalFormatter;

@interface WCEditBreakpointViewController : NSViewController <NSPopoverDelegate> {
	WCBreakpoint *_breakpoint;
	NSPopover *_popover;
}
@property (readwrite,assign,nonatomic) IBOutlet RSHexadecimalFormatter *formatter;

@property (readwrite,retain,nonatomic) WCBreakpoint *breakpoint;

+ (id)editBreakpointViewControllerWithBreakpoint:(WCBreakpoint *)breakpoint;
- (id)initWithBreakpoint:(WCBreakpoint *)breakpoint;

- (IBAction)hideEditBreakpointView:(id)sender;

- (void)showEditBreakpointViewRelativeToRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)hideEditBreakpointView;
@end
