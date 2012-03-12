//
//  RSMemoryMapViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSViewController.h>

@class RSCalculator;

@interface RSMemoryMapViewController : NSViewController {
	RSCalculator *_calculator;
}

@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

@end
