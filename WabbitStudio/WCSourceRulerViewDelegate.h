//
//  WCSourceRulerViewDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceRulerView,WCSourceScanner;

@protocol WCSourceRulerViewDelegate <NSObject>
@required
- (WCSourceScanner *)sourceScannerForSourceRulerView:(WCSourceRulerView *)rulerView;
@end
