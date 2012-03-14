//
//  RSFlashMemoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
