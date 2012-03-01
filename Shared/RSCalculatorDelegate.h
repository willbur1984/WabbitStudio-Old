//
//  RSCalculatorDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>

@class RSCalculator;

@protocol RSCalculatorDelegate <NSObject>
@optional
- (void)calculator:(RSCalculator *)calculator didLoadRomOrSavestateURL:(NSURL *)romOrSavestateURL;
@end
