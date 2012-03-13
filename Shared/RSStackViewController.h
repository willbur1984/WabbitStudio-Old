//
//  RSStackViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"

@class RSCalculator,RSHexadecimalFormatter;

@interface RSStackViewController : JAViewController <NSTableViewDataSource> {
	RSCalculator *_calculator;
	NSUInteger _rowCount;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@property (readwrite,assign,nonatomic) IBOutlet RSHexadecimalFormatter *stackAddressFormatter;

@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

@end
