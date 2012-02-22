//
//  RSTransferFileWindowControllerDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class RSTransferFileWindowController;

@protocol RSTransferFileWindowControllerDelegate <NSObject>
@required
- (NSWindow *)windowForTransferFileWindowControllerSheet:(RSTransferFileWindowController *)transferFileWindowController;
@end
