//
//  RSLightBackgroundTextFieldCell.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSLightBackgroundTextFieldCell.h"

@interface RSLightBackgroundTextFieldCell ()
- (void)_commonInit;
@end

@implementation RSLightBackgroundTextFieldCell
#pragma mark *** Subclass Overrides ***
- (void)setBackgroundStyle:(NSBackgroundStyle)style {
	if (style == NSBackgroundStyleDark)
		[super setBackgroundStyle:style];
	else
		[super setBackgroundStyle:NSBackgroundStyleLight];
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
	[self setBackgroundStyle:NSBackgroundStyleLight];
}
@end
