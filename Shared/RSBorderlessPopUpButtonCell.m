//
//  RSBorderlessPopUpButtonCell.m
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSBorderlessPopUpButtonCell.h"

@interface RSBorderlessPopUpButtonCell ()
- (void)_commonInit;
@end

@implementation RSBorderlessPopUpButtonCell
#pragma mark *** Public Methods ***
- (id)initTextCell:(NSString *)stringValue pullsDown:(BOOL)pullDown {
	if (!(self = [super initTextCell:stringValue pullsDown:pullDown]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if (!(self = [super initWithCoder:coder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	[self setHighlightsBy:NSContentsCellMask];
	[self setShowsStateBy:NSNoCellMask];
}

@end
