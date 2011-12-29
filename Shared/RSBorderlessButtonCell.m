//
//  RSBorderlessButtonCell.m
//  WabbitStudio
//
//  Created by William Towe on 7/20/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSBorderlessButtonCell.h"

@interface RSBorderlessButtonCell ()
- (void)_commonInit;
@end

@implementation RSBorderlessButtonCell
#pragma mark *** Subclass Overrides ***
- (id)initImageCell:(NSImage *)image {
	if (!(self = [super initImageCell:image]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initTextCell:(NSString *)string {
	if (!(self = [super initTextCell:string]))
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
