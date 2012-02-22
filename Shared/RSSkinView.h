//
//  RSSkinView.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSView.h>

@class RSCalculator;

@interface RSSkinView : NSView {
	RSCalculator *_calculator;
}
@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithFrame:(NSRect)frameRect calculator:(RSCalculator *)calculator;
@end
