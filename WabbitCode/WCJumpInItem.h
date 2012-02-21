//
//  WCJumpInItem.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol WCJumpInItem <NSObject>
- (NSString *)jumpInName;
- (NSImage *)jumpInImage;
- (NSURL *)jumpInLocationURL;
- (NSRange)jumpInRange;
@end
