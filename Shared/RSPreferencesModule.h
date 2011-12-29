//
//  RSPreferencesModule.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol RSPreferencesModule <NSObject>
@required
- (NSString *)identifier;
- (NSString *)label;
- (NSImage *)image;
- (NSView *)view;
@optional
- (NSView *)initialFirstResponder;
@end
