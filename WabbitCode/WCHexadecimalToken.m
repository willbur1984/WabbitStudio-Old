//
//  WCHexadecimalToken.m
//  WabbitStudio
//
//  Created by William Towe on 6/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCHexadecimalToken.h"
#import "NSString+RSExtensions.h"

@implementation WCHexadecimalToken

- (NSUInteger)value {
    if (_value == NSUIntegerMax) {
        _value = [self.name valueFromHexadecimalString];
    }
    return _value;
}

@end
