//
//  RSDisplayViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDisplayViewController.h"
#import "RSCalculator.h"

@interface RSDisplayViewController ()

@end

@implementation RSDisplayViewController

- (void)dealloc {
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSDisplayView";
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
