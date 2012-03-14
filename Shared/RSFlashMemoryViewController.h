//
//  RSFlashMemoryViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>
#import "RSCalculatorMemoryView.h"

@class RSCalculator,RSHexadecimalFormatter;

@interface RSFlashMemoryViewController : NSViewController <RSCalculatorMemoryView,NSTableViewDataSource,NSTableViewDelegate> {
	RSCalculator *_calculator;
	NSUInteger _rowCount;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet RSHexadecimalFormatter *memoryColumnFormatter;

@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

@end
