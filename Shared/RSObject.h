//
//  RSObject.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "RSPlistArchiving.h"

extern NSString *const RSObjectClassNameKey;

@interface RSObject : NSObject <RSPlistArchiving>

@end
