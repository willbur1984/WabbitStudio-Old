//
//  WCNavigatorModule.h
//  WabbitStudio
//
//  Created by William Towe on 1/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WCNavigatorModule <NSObject>
@required
- (NSArray *)selectedObjects;
- (void)setSelectedObjects:(NSArray *)objects;

- (NSArray *)selectedModelObjects;
- (void)setSelectedModelObjects:(NSArray *)modelObjects;
@end
