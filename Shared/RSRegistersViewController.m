//
//  RSRegistersViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSRegistersViewController.h"
#import "RSCalculator.h"
#import "RSHexadecimalFormatter.h"

@interface RSRegistersViewController ()

@end

@implementation RSRegistersViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSRegistersView";
}

- (void)loadView {
	[super loadView];
	
	[[self hexadecimalFormatter] setHexadecimalFormat:RSHexadecimalFormatUppercaseUnsignedShort];
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize hexadecimalFormatter=_hexadecimalFormatter;

@synthesize calculator=_calculator;

@end
