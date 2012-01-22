//
//  WCJumpBarCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCJumpBarCell.h"
#import "WCJumpBarComponentCell.h"

@interface WCJumpBarCell ()
- (void)_commonInit;
@end

@implementation WCJumpBarCell
#pragma mark *** Subclass Overrides ***
+ (Class)pathComponentCellClass {
	return [WCJumpBarComponentCell class];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (id)initTextCell:(NSString *)aString {
	if (!(self = [super initTextCell:aString]))
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
	[self setPlaceholderString:NSLocalizedString(@"No Document", @"No Document")];
}

@end
