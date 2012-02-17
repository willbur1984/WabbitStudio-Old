//
//  WCInterfacePerformer.m
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCInterfacePerformer.h"
#import "WCGroup.h"
#import "WCGroupContainer.h"
#import "WCAddToProjectAccessoryViewController.h"
#import "WCDocumentController.h"
#import "NSURL+RSExtensions.h"

@implementation WCInterfacePerformer
+ (WCInterfacePerformer *)sharedPerformer {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer error:(NSError **)outError; {
	return [self addFileURLs:fileURLs toGroupContainer:groupContainer atIndex:0 copyFiles:[[NSUserDefaults standardUserDefaults] boolForKey:WCAddToProjectDestinationCopyItemsKey] error:outError];
}
- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer atIndex:(NSUInteger)index error:(NSError **)outError; {
	return [self addFileURLs:fileURLs toGroupContainer:groupContainer atIndex:index copyFiles:[[NSUserDefaults standardUserDefaults] boolForKey:WCAddToProjectDestinationCopyItemsKey] error:outError];
}
- (BOOL)addFileURLs:(NSArray *)fileURLs toGroupContainer:(WCGroupContainer *)groupContainer atIndex:(NSUInteger)index copyFiles:(BOOL)copyFiles error:(NSError **)outError; {
	for (NSURL *fileURL in fileURLs) {
		if ([fileURL isPackage] && [[fileURL fileUTI] isEqualToString:WCProjectFileUTI])
			continue;
		else if ([fileURL isDirectory]) {
			if ([[fileURL fileName] isEqualToString:NSLocalizedString(@"Build Products", @"Build Products")])
				continue;
			
			if (copyFiles) {
				NSURL *newFileURL = [[[[groupContainer representedObject] fileURL] parentDirectoryURL] URLByAppendingPathComponent:[fileURL lastPathComponent]];
				if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:newFileURL error:outError])
					return NO;
				
				fileURL = newFileURL;
			}
			
			WCGroupContainer *directoryContainer = [WCGroupContainer fileContainerWithFile:[WCGroup fileWithFileURL:fileURL]];
			
			NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:fileURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLIsDirectoryKey,NSURLIsPackageKey,NSURLParentDirectoryURLKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
				return NO;
			}];
			
			NSMutableDictionary *directoryPathsToDirectoryNodes = [NSMutableDictionary dictionaryWithCapacity:0];
			for (NSURL *fileURL in directoryEnumerator) {
				if ([fileURL isPackage] && [[fileURL fileUTI] isEqualToString:WCProjectFileUTI])
					continue;
				else if ([fileURL isDirectory]) {
					if ([[fileURL fileName] isEqualToString:NSLocalizedString(@"Build Products", @"Build Products")])
						continue;
					
					WCGroupContainer *directoryNode = [WCGroupContainer fileContainerWithFile:[WCGroup fileWithFileURL:fileURL]];
					
					[directoryPathsToDirectoryNodes setObject:directoryNode forKey:[fileURL path]];
					
					WCGroupContainer *parentDirectoryNode = [directoryPathsToDirectoryNodes objectForKey:[[fileURL parentDirectoryURL] path]];
					
					if (parentDirectoryNode)
						[[parentDirectoryNode mutableChildNodes] addObject:directoryNode];
					else
						[[directoryContainer mutableChildNodes] addObject:directoryNode];
				}
				else {
					WCFileContainer *childNode = [WCFileContainer fileContainerWithFile:[WCFile fileWithFileURL:fileURL]];
					WCFileContainer *parentDirectoryNode = [directoryPathsToDirectoryNodes objectForKey:[[fileURL parentDirectoryURL] path]];
					
					if (parentDirectoryNode)
						[[parentDirectoryNode mutableChildNodes] addObject:childNode];
					else
						[[directoryContainer mutableChildNodes] addObject:childNode];
				}
			}
			
			[[groupContainer mutableChildNodes] insertObject:directoryContainer atIndex:index++];
		}
		else {
			if (copyFiles) {
				NSURL *newFileURL = [[[[groupContainer representedObject] fileURL] parentDirectoryURL] URLByAppendingPathComponent:[fileURL lastPathComponent]];
				if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:newFileURL error:outError])
					return NO;
				
				fileURL = newFileURL;
			}
			
			WCFileContainer *fileContainer = [WCFileContainer fileContainerWithFile:[WCFile fileWithFileURL:fileURL]];
			
			[[groupContainer mutableChildNodes] insertObject:fileContainer atIndex:index++];
		}
	}
	return YES;
}
@end
