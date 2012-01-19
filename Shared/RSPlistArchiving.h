//
//  RSPlistArchiving.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

/** Protocol that our model objects must conform to.
 
 This allows reading and writing our model objects as plist's.
 
 */

@protocol RSPlistArchiving <NSObject>
@required
/** @name Required methods */

/** Returns the plist representation of the receiver, all values must be plist appropriate objects.
 
 @return Returns the plist representation of the receiver.
 
 */
- (NSDictionary *)plistRepresentation;

@optional
/** @name Optional methods */

/** Initializes the receiver with `plistRepresentation`.
 
 @param plistRepresentation The plist the receiver should use to initialize itself.
 @return Returns an initialized instance of the receiver, using the values provided in `plistRepresentation`.
 
 */
- (id)initWithPlistRepresentation:(NSDictionary *)plistRepresentation;
@end
