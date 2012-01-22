//
//  RSRaisedBackgroundTextFieldCell.m
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "RSRaisedBackgroundTextFieldCell.h"

@interface RSRaisedBackgroundTextFieldCell ()
- (void)_commonInit;
@end

@implementation RSRaisedBackgroundTextFieldCell
#pragma mark *** Subclass Overrides ***
- (void)setBackgroundStyle:(NSBackgroundStyle)style {
	if (style == NSBackgroundStyleDark)
		[super setBackgroundStyle:style];
	else
		[super setBackgroundStyle:NSBackgroundStyleRaised];
}

- (id)initTextCell:(NSString *)aString {
	if (!(self = [super initTextCell:aString]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
#pragma mark *** Private Methods ***
- (void)_commonInit; {
	[self setBackgroundStyle:NSBackgroundStyleRaised];
}
@end
