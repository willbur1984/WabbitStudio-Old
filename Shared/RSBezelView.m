//
//  RSBezelView.m
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSBezelView.h"
#import "RSVerticallyCenteredTextFieldCell.h"

@interface RSBezelView ()
- (void)_commonInit;
@end

@implementation RSBezelView
#pragma mark *** Subclass Overrides ***
- (id)initWithFrame:(NSRect)frameRect {
	if (!(self = [super initWithFrame:frameRect]))
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

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

#pragma mark *** Public Methods ***

#pragma mark Properties
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
		[self setFrame:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)];
		
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
		NSSize newSize = [_stringCell cellSizeForBounds:NSMakeRect(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
		
		newSize.width += 8.0;
		newSize.height += 4.0;
		
		[self setFrameSize:newSize];
		
		[self setImage:nil];
		
		[self setNeedsDisplay:YES];
	}
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	_stringCell = [[RSVerticallyCenteredTextFieldCell alloc] initTextCell:@""];
	[_stringCell setFont:[NSFont boldSystemFontOfSize:20.0]];
	[_stringCell setTextColor:[NSColor whiteColor]];
	[_stringCell setBackgroundStyle:NSBackgroundStyleLowered];
	[_stringCell setLineBreakMode:NSLineBreakByClipping];
	[_stringCell setAlignment:NSCenterTextAlignment];
}
@end
