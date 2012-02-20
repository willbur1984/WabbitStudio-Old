//
//  WCProjectTemplate.m
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProjectTemplate.h"

@implementation WCProjectTemplate
+ (id)projectTemplateWithURL:(NSURL *)url; {
	return [self templateWithURL:url error:NULL];
}
@end
