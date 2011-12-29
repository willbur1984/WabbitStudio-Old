//
//  WCNumberToken.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceToken.h"

@interface WCNumberToken : WCSourceToken {
	NSInteger _value;
}
@property (readonly,nonatomic) NSInteger value;
@end
