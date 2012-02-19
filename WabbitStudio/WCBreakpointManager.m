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

NSString *const WCBreakpointManagerDidAddFileBreakpointNotification = @"WCBreakpointManagerDidAddFileBreakpointNotification";
NSString *const WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey = @"WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey";

NSString *const WCBreakpointManagerDidRemoveFileBreakpointNotification = @"WCBreakpointManagerDidRemoveFileBreakpointNotification";
NSString *const WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey = @"WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey";

NSString *const WCBreakpointManagerDidChangeBreakpointActiveNotification = @"WCBreakpointManagerDidChangeBreakpointActiveNotification";
NSString *const WCBreakpointManagerDidChangeBreakpointActiveChangedBreakpointUserInfoKey = @"WCBreakpointManagerDidChangeBreakpointActiveChangedBreakpointUserInfoKey";

NSString *const WCBreakpointManagerDidChangeBreakpointsEnabledNotification = @"WCBreakpointManagerDidChangeBreakpointsEnabledNotification";

@interface WCBreakpointManager ()
@property (readonly,nonatomic) NSMutableSet *fileBreakpoints;
@end

@implementation WCBreakpointManager
- (void)dealloc {
	_projectDocument = nil;
	[_fileBreakpoints release];
	[_filesToFileBreakpointsSortedByLocation release];
	[_filesWithFileBreakpointsSortedByName release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self && [keyPath isEqualToString:@"active"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidChangeBreakpointActiveNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:object,WCBreakpointManagerDidChangeBreakpointActiveChangedBreakpointUserInfoKey, nil]];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	_filesToFileBreakpointsSortedByLocation = [[NSMapTable mapTableWithWeakToStrongObjects] retain];
	_filesWithFileBreakpointsSortedByName = [[NSMutableArray alloc] initWithCapacity:0];
	_fileBreakpoints = [[NSMutableSet alloc] initWithCapacity:0];
	_breakpointManagerFlags.breakpointsEnabled = YES;
	
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
	
	[fileBreakpoint addObserver:self forKeyPath:@"active" options:NSKeyValueObservingOptionNew context:self];
	
	[fileBreakpoints addObject:fileBreakpoint];
	[[self fileBreakpoints] addObject:fileBreakpoint];
	
	[fileBreakpoints sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
		if ([obj1 rangeValue].location < [obj2 rangeValue].location)
			return NSOrderedAscending;
		else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
			return NSOrderedDescending;
		return NSOrderedSame;
	}], nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidAddFileBreakpointNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileBreakpoint,WCBreakpointManagerDidAddFileBreakpointNewFileBreakpointUserInfoKey, nil]];
}
- (void)removeFileBreakpoint:(WCFileBreakpoint *)fileBreakpoint {
	NSMutableArray *fileBreakpoints = [[self filesToFileBreakpointsSortedByLocation] objectForKey:[fileBreakpoint file]];
	
	[[fileBreakpoint retain] autorelease];
	
	[fileBreakpoint removeObserver:self forKeyPath:@"active" context:self];
	
	[fileBreakpoints removeObject:fileBreakpoint];
	[[self fileBreakpoints] removeObject:fileBreakpoint];
	
	if (![fileBreakpoints count]) {
		[[self filesToFileBreakpointsSortedByLocation] removeObjectForKey:[fileBreakpoint file]];
		[_filesWithFileBreakpointsSortedByName removeObject:[fileBreakpoint file]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidRemoveFileBreakpointNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileBreakpoint,WCBreakpointManagerDidRemoveFileBreakpointOldFileBreakpointUserInfoKey, nil]];
}

- (void)performCleanup; {
	for (WCFileBreakpoint *fileBreakpoint in [self fileBreakpoints])
		[fileBreakpoint removeObserver:self forKeyPath:@"active" context:self];
}

@synthesize projectDocument=_projectDocument;
@synthesize filesToFileBreakpointsSortedByLocation=_filesToFileBreakpointsSortedByLocation;
@synthesize filesWithFileBreakpointsSortedByName=_filesWithFileBreakpointsSortedByName;
@synthesize fileBreakpoints=_fileBreakpoints;
@dynamic breakpointsEnabled;
- (BOOL)breakpointsEnabled {
	return _breakpointManagerFlags.breakpointsEnabled;
}
- (void)setBreakpointsEnabled:(BOOL)breakpointsEnabled {
	_breakpointManagerFlags.breakpointsEnabled = breakpointsEnabled;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:WCBreakpointManagerDidChangeBreakpointsEnabledNotification object:self];
}

@end
