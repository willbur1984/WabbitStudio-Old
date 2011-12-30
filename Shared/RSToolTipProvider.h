//
//  RSToolTipProvider.h
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

static NSFont *RSToolTipProviderDefaultFont() {
	return [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
}
static NSDictionary *RSToolTipProviderDefaultAttributes() {
	return [NSDictionary dictionaryWithObjectsAndKeys:RSToolTipProviderDefaultFont(),NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
}

@protocol RSToolTipProvider <NSObject>
@required
- (NSAttributedString *)attributedToolTip;
@end
