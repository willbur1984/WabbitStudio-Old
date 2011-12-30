//
//  RSFindOptionsViewControllerDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class RSFindOptionsViewController;

@protocol RSFindOptionsViewControllerDelegate <NSObject>
@optional
- (void)findOptionsViewControllerDidClose:(RSFindOptionsViewController *)viewController;
- (void)findOptionsViewControllerDidChangeFindOptions:(RSFindOptionsViewController *)viewController;
@end
