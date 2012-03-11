//
//  RSFlagsViewController.m
//  WabbitStudio
//
//  Created by William Towe on 3/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFlagsViewController.h"
#import "RSCalculator.h"

@interface RSFlagsViewController ()

@end

@implementation RSFlagsViewController

- (void)dealloc {
	[_calculator release];
	[super dealloc];
}

- (NSString *)nibName {
	return @"RSFlagsView";
}

- (id)initWithCalculator:(RSCalculator *)calculator; {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	_calculator = [calculator retain];
	
	return self;
}

@synthesize calculator=_calculator;

@end
