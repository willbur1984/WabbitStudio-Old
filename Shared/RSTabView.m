//
//  RSTabView.m
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import "RSTabView.h"
#import "RSEmptyContentCell.h"

@implementation RSTabView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[_emptyContentStringCell release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
	if ([self shouldDrawEmptyContentString]) {
		[_emptyContentStringCell setEmptyContentStringStyle:[self emptyContentStringStyle]];
		[_emptyContentStringCell setStringValue:[self emptyContentString]];
		[_emptyContentStringCell drawWithFrame:[self bounds] inView:self];
	}
}
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
	if (!(self = [super initWithCoder:decoder]))
		return nil;
	
	_emptyContentStringCell = [[RSEmptyContentCell alloc] initTextCell:@""];
	
	return self;
}
#pragma mark *** Public Methods ***

#pragma mark Properties
@dynamic emptyContentString;
- (NSString *)emptyContentString {
	return NSLocalizedString(@"No Content", @"No Content");
}
@dynamic shouldDrawEmptyContentString;
- (BOOL)shouldDrawEmptyContentString {
	return (![self numberOfTabViewItems]);
}
@dynamic emptyContentStringStyle;
- (RSEmptyContentStringStyle)emptyContentStringStyle {
	return RSEmptyContentStringStyleNormal;
}

@end
