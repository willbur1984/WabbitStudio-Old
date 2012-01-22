//
//  WCProjectNavigatorCellView.h
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableCellView.h>

@class WCProjectNavigatorViewController;

@interface WCProjectNavigatorCellView : NSTableCellView <NSControlTextEditingDelegate> {
	BOOL _didBeginEditingNotificationReceived;
}
@property (readwrite,assign,nonatomic) IBOutlet WCProjectNavigatorViewController *projectNavigatorViewController;
@end
