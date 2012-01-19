//
//  WCDocumentController.m
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCDocumentController.h"

NSString *const WCAssemblyFileUTI = @"org.revsoft.wabbitcode.assembly";
NSString *const WCIncludeFileUTI = @"org.revsoft.wabbitcode.include";
NSString *const WCActiveServerIncludeFileUTI = @"com.panic.coda.active-server-include-file";
NSString *const WCProjectFileUTI = @"org.revsoft.wabbitstudio.project";

@implementation WCDocumentController
@dynamic recentProjectURLs;
- (NSArray *)recentProjectURLs {
	NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
	
	for (NSURL *documentURL in [self recentDocumentURLs]) {
		if ([[self typeForContentsOfURL:documentURL error:NULL] isEqualToString:WCProjectFileUTI])
			[retval addObject:documentURL];
	}
	
	return [[retval copy] autorelease];
}
@end
