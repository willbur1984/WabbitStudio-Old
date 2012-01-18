//
//  RSFileReferenceDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSFileReference;

@protocol RSFileReferenceDelegate <NSObject>
@required
- (void)fileReference:(RSFileReference *)fileReference wasMovedToURL:(NSURL *)url;
- (void)fileReferenceWasDeleted:(RSFileReference *)fileReference;
@end
