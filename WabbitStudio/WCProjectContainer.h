//
//  WCProjectContainer.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCGroupContainer.h"

@class WCProject;

@interface WCProjectContainer : WCGroupContainer

@property (readonly,nonatomic) WCProject *project;

+ (id)projectContainerWithProject:(WCProject *)project;
- (id)initWithProject:(WCProject *)project;
@end
