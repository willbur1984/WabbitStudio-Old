//
//  RSRegularMemoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSRegularMemoryViewController.h"
#import "RSCalculator.h"

@interface RSRegularMemoryViewController ()

@end

@implementation RSRegularMemoryViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSRegularMemoryView";
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
