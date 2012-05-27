//
//  WCConsoleTextView.m
//  WabbitStudio
//
//  Created by William Towe on 5/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCConsoleTextView.h"

@interface WCConsoleTextView ()
- (void)_commonInit;
@end

@implementation WCConsoleTextView

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

- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    if (self.shouldDrawEmptyContentString) {
        [_emptyContentCell setEmptyContentStringStyle:[self emptyContentStringStyle]];
		[_emptyContentCell setStringValue:[self emptyContentString]];
		[_emptyContentCell drawWithFrame:[self bounds] inView:self];
    }
}

@dynamic emptyContentString;
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Build Output", @"No Build Output");
}
@dynamic shouldDrawEmptyContentString;
- (BOOL)shouldDrawEmptyContentString {
	return (!self.string.length);
}
@dynamic emptyContentStringStyle;
- (RSEmptyContentStringStyle)emptyContentStringStyle {
	return RSEmptyContentStringStyleNormal;
}

- (void)_commonInit; {
    _emptyContentCell = [[RSEmptyContentCell alloc] initTextCell:@""];
}

@end
