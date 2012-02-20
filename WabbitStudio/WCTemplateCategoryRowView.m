//
//  WCTemplateCategoryRowView.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplateCategoryRowView.h"
#import "WCTemplateCategory.h"

@implementation WCTemplateCategoryRowView

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
	[super drawBackgroundInRect:dirtyRect];
	
	WCTemplateCategory *category = [[self viewAtColumn:0] objectValue];
	
	if ([category isHeader]) {
		static NSGradient *gradient;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor lightGrayColor]];
		});
		
		[gradient drawInRect:dirtyRect angle:90.0];
		[[NSColor gridColor] setFill];
		NSRectFill(NSMakeRect(NSMinX(dirtyRect), NSMinY(dirtyRect), NSWidth(dirtyRect), 1.0));
		NSRectFill(NSMakeRect(NSMinX(dirtyRect), NSMaxY(dirtyRect)-1.0, NSWidth(dirtyRect), 1.0));
	}
}

@end
