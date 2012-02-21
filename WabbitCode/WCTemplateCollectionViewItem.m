//
//  WCTemplateCollectionViewItem.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCTemplateCollectionViewItem.h"

@interface WCTemplateCollectionViewItem ()

@end

@implementation WCTemplateCollectionViewItem

- (NSString *)nibName {
	return @"WCTemplateCollectionView";
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	
	[[self imageView] setNeedsDisplay:YES];
	[[self textField] setNeedsDisplay:YES];
}

@end
