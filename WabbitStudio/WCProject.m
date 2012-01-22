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
#pragma mark *** Subclass Overrides ***
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
#pragma mark *** Public Methods ***
+ (id)projectWithDocument:(WCProjectDocument *)document; {
	return [[(WCProject *)[[self class] alloc] initWithDocument:document] autorelease];
}
- (id)initWithDocument:(WCProjectDocument *)document; {
	if (!(self = [super initWithFileURL:[document fileURL]]))
		return nil;
	
	_document = document;
	
	return self;
}
#pragma mark Properties
@synthesize document=_document;
@dynamic fileStatus;
- (NSString *)fileStatus {
	return NSLocalizedString(@"This project is fantastic", @"This project is fantastic");
}
@end
