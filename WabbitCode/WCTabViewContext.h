//
//  WCTabViewContext.h
//  WabbitStudio
//
//  Created by William Towe on 1/29/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCTabViewController;

@protocol WCTabViewContext <NSObject>
@required
- (WCTabViewController *)tabViewController;
@end
