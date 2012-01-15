//
//  RSNavigatorControlCell.m
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSNavigatorControlCell.h"

@interface RSNavigatorControlCell ()
- (void)_commonInit;
@end

@implementation RSNavigatorControlCell

- (id)initImageCell:(NSImage *)image {
	if (!(self = [super initImageCell:image]))
		return nil;
	
	[self _commonInit];
	
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (void)_commonInit; {
	[self setHighlightsBy:NSContentsCellMask];
	[self setShowsStateBy:NSNoCellMask];
}
@end
