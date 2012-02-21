//
//  WCOpenPanelAccessoryViewController.m
//  WabbitStudio
//
//  Created by William Towe on 2/20/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCOpenPanelAccessoryViewController.h"
#import "EncodingManager.h"

@implementation WCOpenPanelAccessoryViewController

- (id)init {
	if (!(self = [super initWithNibName:[self nibName] bundle:nil]))
		return nil;
	
	return self;
}

- (NSString *)nibName {
	return @"WCOpenPanelAccessoryView";
}

- (void)loadView {
	[super loadView];

	[[EncodingManager sharedInstance] setupPopUpCell:[[self popUpButton] cell] selectedEncoding:NoStringEncoding withDefaultEntry:YES];
}

@synthesize popUpButton=_popUpButton;

@end
