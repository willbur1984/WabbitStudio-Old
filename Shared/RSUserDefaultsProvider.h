//
//  RSUserDefaultsProvider.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol RSUserDefaultsProvider <NSObject>
@required
+ (NSDictionary *)userDefaults;
@end
