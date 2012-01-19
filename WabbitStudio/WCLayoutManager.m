//
//  WCLayoutManager.m
//  WabbitStudio
//
//  Created by William Towe on 1/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCLayoutManager.h"

@implementation WCLayoutManager
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[super dealloc];
}
@end
