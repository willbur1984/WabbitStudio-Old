//
//  RSDisassemblyViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "RSTableViewDelegate.h"
#include "disassemble.h"

@class RSCalculator;

@interface RSDisassemblyViewController : JAViewController <RSTableViewDelegate,NSTableViewDataSource> {
	RSCalculator *_calculator;
	Z80_info_t *_z80_info;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;

@property (readonly,nonatomic) RSCalculator *calculator;
@property (readonly,nonatomic) Z80_info_t *Z80_infos;

- (id)initWithCalculator:(RSCalculator *)calculator;

- (void)jumpToAddress:(uint16_t)address;
@end
