//
//  WCGroupContainer.h
//  WabbitStudio
//
//  Created by William Towe on 1/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFileContainer.h"

@class WCGroup;

@interface WCGroupContainer : WCFileContainer
@property (readonly,nonatomic) WCGroup *group;
@end
