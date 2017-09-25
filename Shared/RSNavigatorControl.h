//
//  RSNavigatorControl.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AppKit/NSControl.h>
#import "RSNavigatorControlDataSource.h"
#import "RSNavigatorControlDelegate.h"

@interface RSNavigatorControl : NSControl {
	NSMutableArray *_cells;
	NSArray *_itemIdentifiers;
	NSString *_selectedItemIdentifier;
	__unsafe_unretained id <RSNavigatorControlDataSource> _dataSource;
	__unsafe_unretained id <RSNavigatorControlDelegate> _delegate;
	NSGradient *_fillGradient;
	NSGradient *_alternateFillGradient;
	NSColor *_bottomFillColor;
	NSColor *_alternateBottomFillColor;
	NSGradient *_selectedFillGradient;
	id _windowDidBecomeKeyObservingToken;
	id _windowDidResignKeyObservingToken;
}
@property (readwrite,assign,nonatomic) IBOutlet id <RSNavigatorControlDataSource> dataSource;
@property (readwrite,assign,nonatomic) IBOutlet id <RSNavigatorControlDelegate> delegate;
@property (readwrite,assign,nonatomic) IBOutlet NSView *contentView;

@property (readwrite,copy,nonatomic) NSString *selectedItemIdentifier;

- (void)reloadData;

@end
