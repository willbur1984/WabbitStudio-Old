//
//  RSDisassemblyViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSTableViewDelegate.h"
#include "disassemble.h"

@class RSCalculator;

@interface RSDisassemblyViewController : NSViewController <RSTableViewDelegate,NSTableViewDataSource> {
	RSCalculator *_calculator;
	Z80_info_t *_z80_info;
}
@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

@end
