//
//  RSRegistersViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>

@class RSCalculator,RSHexadecimalFormatter;

@interface RSRegistersViewController : NSViewController {
	RSCalculator *_calculator;
}
@property (readwrite,assign,nonatomic) IBOutlet RSHexadecimalFormatter *hexadecimalFormatter;

@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

@end
