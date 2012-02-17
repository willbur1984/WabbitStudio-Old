//
//  WCSourceScrollView.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSScrollView.h>
#import "WCSourceScrollViewDelegate.h"

@interface WCSourceScrollView : NSScrollView {
	__weak id <WCSourceScrollViewDelegate> _delegate;
}
@property (readwrite,assign,nonatomic) IBOutlet id <WCSourceScrollViewDelegate> delegate;
@end
