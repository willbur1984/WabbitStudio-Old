//
//  RSBezelView.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSBezelView.h"

@interface RSBezelView ()
- (void)_commonInit;
@end

@implementation RSBezelView

- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    if ([self image])
		[[self image] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	else if ([[self string] length]) {
		[[[NSColor darkGrayColor] colorWithAlphaComponent:0.9] setFill];
		[[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:10.0 yRadius:10.0] fill];
		
		[_stringCell drawWithFrame:[self bounds] inView:self];
	}
}

@dynamic image;
- (NSImage *)image {
	return _image;
}
- (void)setImage:(NSImage *)image {
	if (_image == image)
		return;
	
	[_image release];
	_image = [image retain];
	
	if (_image) {
		NSRect oldFrame = [self frame];
		[self setFrame:NSMakeRect(NSMinX(oldFrame), NSMinY(oldFrame), [image size].width, [image size].height)];
		
		[self setString:@""];
		
		[self setNeedsDisplay:YES];
	}
}

@dynamic string;
- (NSString *)string {
	return [_stringCell stringValue];
}
- (void)setString:(NSString *)string {
	[_stringCell setStringValue:string];
	
	if ([[_stringCell stringValue] length]) {
		static const NSSize maxSize = (NSSize){275.0,225.0};
		NSRect oldFrame = [self frame];
		NSSize newSize = [_stringCell cellSizeForBounds:NSMakeRect(0, 0, maxSize.width, maxSize.height)];
		
		[self setFrame:NSMakeRect(NSMinX(oldFrame), NSMinY(oldFrame), (newSize.width > maxSize.width)?maxSize.width:newSize.width, (newSize.height > maxSize.height)?maxSize.height:newSize.height)];
		
		[self setImage:nil];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)_commonInit; {
	_stringCell = [[NSTextFieldCell alloc] initTextCell:@""];
	[_stringCell setFont:[NSFont controlContentFontOfSize:18.0]];
	[_stringCell setTextColor:[NSColor whiteColor]];
}
@end
