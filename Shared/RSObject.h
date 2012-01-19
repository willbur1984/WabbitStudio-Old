//
//  RSObject.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "RSPlistArchiving.h"

extern NSString *const RSObjectClassNameKey;

/** Base class for our object model.
 
 RSObject conforms to `RSPlistArchiving` so that subclasses don't have to insert their class name into the plist return from `-(NSDictionary *)plistRepresentation`.
 
 @warning *Important:* Overrides of '-(NSDictionary *)plistRepresentation' must call super first and create a mutable copy of the returned NSDictionary object. Add the desired values to the copy and return it.
 */

@interface RSObject : NSObject <RSPlistArchiving>

@end
