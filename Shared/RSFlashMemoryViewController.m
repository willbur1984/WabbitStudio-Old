//
//  RSFlashMemoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/14/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSFlashMemoryViewController.h"
#import "RSCalculator.h"
#import "RSHexadecimalFormatter.h"

@interface RSFlashMemoryViewController ()
@property (readwrite,assign,nonatomic) NSUInteger rowCount;

- (void)_updateMemoryTableColumns;
@end

@implementation RSFlashMemoryViewController

- (void)dealloc {
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSFlashMemoryView";
}

- (void)loadView {
	[super loadView];
	
	[[self memoryColumnFormatter] setHexadecimalFormat:RSHexadecimalFormatUnsignedChar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[[[self tableView] enclosingScrollView] contentView]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:[[[self tableView] enclosingScrollView] contentView]];
	
	[self _updateMemoryTableColumns];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [self rowCount];
}

static NSString *const kAddressColumnIdentifier = @"address";

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
}

- (void)jumpToMemoryAddress:(uint16_t)memoryAddress {
	
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize tableView=_tableView;

@synthesize calculator=_calculator;
@synthesize rowCount=_rowCount;
- (void)setRowCount:(NSUInteger)rowCount {
	_rowCount = rowCount;
	
	[[self tableView] reloadData];
}

- (void)_updateMemoryTableColumns; {
	
}

@end
