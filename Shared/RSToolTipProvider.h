//
//  RSToolTipProvider.h
//  WabbitEdit
//
//  Created by William Towe on 7/7/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCFontAndColorTheme.h"
#import "WCFontAndColorThemeManager.h"

static NSFont *RSToolTipProviderDefaultFont() {
    NSFont *font = [[[WCFontAndColorThemeManager sharedManager] currentTheme] plainTextFont];
    
	return [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:[font pointSize]]];
}
static NSDictionary *RSToolTipProviderDefaultAttributes() {
	return [NSDictionary dictionaryWithObjectsAndKeys:RSToolTipProviderDefaultFont(),NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
}

@protocol RSToolTipProvider <NSObject>
@required
- (NSAttributedString *)attributedToolTip;
@end
