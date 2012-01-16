//
//  WCProject.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCProject.h"
#import "WCProjectDocument.h"

@implementation WCProject
- (void)dealloc {
	_document = nil;
	[super dealloc];
}

- (NSString *)fileName {
	return [[[self document] displayName] stringByDeletingPathExtension];
}
- (NSImage *)fileIcon {
	return [NSImage imageNamed:@"project"];
}

+ (id)projectWithDocument:(WCProjectDocument *)document; {
	return [[[[self class] alloc] initWithDocument:document] autorelease];
}
- (id)initWithDocument:(WCProjectDocument *)document; {
	if (!(self = [super initWithFileURL:[document fileURL]]))
		return nil;
	
	_document = document;
	
	return self;
}

@synthesize document=_document;
@end
