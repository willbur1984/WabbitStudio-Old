//
//  NSURL+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 2/29/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "NSURL+WCExtensions.h"
#import "NSURL+RSExtensions.h"
#import "WCDocumentController.h"

@implementation NSURL (WCExtensions)
- (BOOL)isSourceFileURL; {
	NSString *fileUTI = [self fileUTI];
	
	return ([fileUTI isEqualToString:WCAssemblyFileUTI] ||
			[fileUTI isEqualToString:WCIncludeFileUTI] ||
			[fileUTI isEqualToString:WCActiveServerIncludeFileUTI]);
}
@end
