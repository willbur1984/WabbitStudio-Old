//
//  WCProject.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCGroup.h"

@class WCProjectDocument;

@interface WCProject : WCGroup {
	__weak WCProjectDocument *_document;
}
@property (readonly,nonatomic) WCProjectDocument *document;

+ (id)projectWithDocument:(WCProjectDocument *)document;
- (id)initWithDocument:(WCProjectDocument *)document;
@end
