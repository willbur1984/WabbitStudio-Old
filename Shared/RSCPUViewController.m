//
//  RSCPUViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSCPUViewController.h"
#import "RSCalculator.h"

@interface RSCPUViewController ()

@end

@implementation RSCPUViewController

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSCPUView";
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
