//
//  RSPlistArchiving.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol RSPlistArchiving <NSObject>
@required
- (NSDictionary *)plistRepresentation;
@optional
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation;
@end
