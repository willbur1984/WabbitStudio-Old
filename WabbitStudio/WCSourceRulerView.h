//
//  WCSourceRulerView.h
//  WabbitEdit
//
//  Created by William Towe on 12/26/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCLineNumberRulerView.h"
#import "WCSourceRulerViewDelegate.h"

@interface WCSourceRulerView : WCLineNumberRulerView {
	__weak id <WCSourceRulerViewDelegate> _delegate;
	NSUInteger _clickedLineNumber;
}
@property (readwrite,assign,nonatomic) id <WCSourceRulerViewDelegate> delegate;

- (void)drawCodeFoldingRibbonInRect:(NSRect)ribbonRect;
@end
