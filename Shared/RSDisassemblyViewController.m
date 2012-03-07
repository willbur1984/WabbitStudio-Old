//
//  RSDisassemblyViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDisassemblyViewController.h"
#import "RSCalculator.h"
#import "RSTableView.h"


@interface RSDisassemblyViewController ()

@end

@implementation RSDisassemblyViewController
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	free(_z80_info);
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSDisassemblyView";
}

- (void)loadView {
	_z80_info = calloc(sizeof(Z80_info_t), UINT16_MAX);
	
	disassemble([[self calculator] calculator], REGULAR, addr_to_waddr(&([[self calculator] calculator]->mem_c), 0), UINT16_MAX, _z80_info);
	
	[super loadView];
}

static NSString *const kAddressColumnIdentifier = @"address";
static NSString *const kDataColumnIdentifier = @"data";
static NSString *const kDisassemblyColumnIdentifier = @"disassembly";
static NSString *const kSizeColumnIdentifier = @"size";

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return UINT16_MAX;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([[tableColumn identifier] isEqualToString:kAddressColumnIdentifier]) {
		Z80_info_t info = _z80_info[row];
		
		return [NSNumber numberWithUnsignedShort:info.waddr.addr];
	}
	else if ([[tableColumn identifier] isEqualToString:kDataColumnIdentifier]) {
		Z80_info_t info = _z80_info[row];
		uint32_t offset, total = 0;
		
		for (offset=0; offset<info.size; offset++) {
			total += mem_read(&([[self calculator] calculator]->mem_c), info.waddr.addr+offset);
			total <<= 8;
		}
		
		return [NSNumber numberWithInt:total];
	}
	else if ([[tableColumn identifier] isEqualToString:kDisassemblyColumnIdentifier]) {
		Z80_info_t info = _z80_info[row];
		
		return [NSString stringWithCString:info.expanded encoding:NSUTF8StringEncoding];
	}
	else if ([[tableColumn identifier] isEqualToString:kSizeColumnIdentifier]) {
		Z80_info_t info = _z80_info[row];
		
		return [NSNumber numberWithInt:info.size];
	}
	return nil;
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
