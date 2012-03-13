//
//  RSRegularMemoryTableHeaderView.m
//  WabbitStudio
//
//  Created by William Towe on 3/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSRegularMemoryTableHeaderView.h"

@implementation RSRegularMemoryTableHeaderView

- (NSRect)headerRectOfColumn:(NSInteger)column {
	NSRect addressHeaderRect = [super headerRectOfColumn:0];
	
	if (column)
		return NSMakeRect(NSMaxX(addressHeaderRect), NSMinY(addressHeaderRect), NSWidth([self bounds])-NSWidth(addressHeaderRect), NSHeight(addressHeaderRect));
	return addressHeaderRect;
}

@end
