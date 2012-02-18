//
//  WCBreakpointManager.m
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCBreakpointManager.h"
#import "WCProjectDocument.h"
#import "WCFile.h"
#import "WCFileBreakpoint.h"

NSString *const WCBreakpointManagerDidAddBreakpointNotification = @"WCBreakpointManagerDidAddBreakpointNotification";
NSString *const WCBreakpointManagerDidAddBreakpointNewBreakpointUserInfoKey = @"WCBreakpointManagerDidAddBreakpointNewBreakpointUserInfoKey";

NSString *const WCBreakpointManagerDidRemoveBreakpointNotification = @"WCBreakpointManagerDidRemoveBreakpointNotification";
NSString *const WCBreakpointManagerDidRemoveBreakpointOldBreakpointUserInfoKey = @"WCBreakpointManagerDidRemoveBreakpointOldBreakpointUserInfoKey";

NSString *const WCBreakpointManagerDidChangeBreakpointActiveNotification = @"WCBreakpointManagerDidChangeBreakpointActiveNotification";

@implementation WCBreakpointManager
- (void)dealloc {
	_projectDocument = nil;
	[_filesToFileBreakpointsSortedByLocation release];
	[_filesWithFileBreakpointsSortedByName release];
	[super dealloc];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	_filesToFileBreakpointsSortedByLocation = [[NSMapTable mapTableWithWeakToStrongObjects] retain];
	_filesWithFileBreakpointsSortedByName = [[NSMutableArray alloc] initWithCapacity:0];
	
	return self;
}

- (void)addFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint {
	NSMutableArray *fileBreakpoints = [[self filesToFileBreakpointsSortedByLocation] objectForKey:[fileBreakpoint file]];
	
	if (!fileBreakpoints) {
		fileBreakpoints = [NSMutableArray arrayWithCapacity:0];
		
		[[self filesToFileBreakpointsSortedByLocation] setObject:fileBreakpoints forKey:[fileBreakpoint file]];
		[_filesWithFileBreakpointsSortedByName addObject:[fileBreakpoint file]];
		[_filesWithFileBreakpointsSortedByName sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
	}
	
	[fileBreakpoints addObject:fileBreakpoint];
	
	[fileBreakpoints sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
		if ([obj1 rangeValue].location < [obj2 rangeValue].location)
			return NSOrderedAscending;
		else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}], nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidAddBreakpointNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileBreakpoint,WCBreakpointManagerDidAddBreakpointNewBreakpointUserInfoKey, nil]];
}
- (void)removeFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint {
	NSMutableArray *fileBreakpoints = [[self filesToFileBreakpointsSortedByLocation] objectForKey:[fileBreakpoint file]];
	
	[[fileBreakpoint retain] autorelease];
	
	[fileBreakpoints removeObject:fileBreakpoint];
	
	if (![fileBreakpoints count]) {
		[[self filesToFileBreakpointsSortedByLocation] removeObjectForKey:[fileBreakpoint file]];
		[_filesWithFileBreakpointsSortedByName removeObject:[fileBreakpoint file]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidRemoveBreakpointNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileBreakpoint,WCBreakpointManagerDidRemoveBreakpointOldBreakpointUserInfoKey, nil]];
}

@synthesize projectDocument=_projectDocument;
@synthesize filesToFileBreakpointsSortedByLocation=_filesToFileBreakpointsSortedByLocation;
@synthesize filesWithFileBreakpointsSortedByName=_filesWithFileBreakpointsSortedByName;

@end
