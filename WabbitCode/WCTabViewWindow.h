//
//  WCTabViewWindow.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "KBResponderNotifyingWindow.h"

@class WCTabViewController;

@interface WCTabViewWindow : KBResponderNotifyingWindow
@property (readwrite,assign,nonatomic) IBOutlet WCTabViewController *tabViewController;
@end
