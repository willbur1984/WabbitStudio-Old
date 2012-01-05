//
//  RSBezelWindowController.h
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class RSBezelView;

@interface RSBezelWidgetManager : NSWindowController {
	NSTimer *_fadeTimer;
}
@property (readwrite,assign,nonatomic) IBOutlet RSBezelView *bezelView;

+ (RSBezelWidgetManager *)sharedWindowController;

- (void)showImage:(NSImage *)image atPoint:(NSPoint)point;
- (void)showImage:(NSImage *)image centeredInView:(NSView *)view;

- (void)showString:(NSString *)string atPoint:(NSPoint)point;
- (void)showString:(NSString *)string centeredInView:(NSView *)view;
@end
