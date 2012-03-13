//
//  RSCalculatorMemoryView.h
//  WabbitStudio
//
//  Created by William Towe on 3/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol RSCalculatorMemoryView <NSObject>
@required
- (void)jumpToMemoryAddress:(uint16_t)memoryAddress;
@end
