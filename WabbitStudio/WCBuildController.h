//
//  WCBuildController.h
//  WabbitStudio
//
//  Created by William Towe on 2/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCProjectDocument;

@interface WCBuildController : NSObject {
	__weak WCProjectDocument *_projectDocument;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

- (void)build;
- (void)buildAndRun;
@end
