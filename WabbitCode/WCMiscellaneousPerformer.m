//
//  WCMiscellaneousPerformer.m
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WCMiscellaneousPerformer.h"

@implementation WCMiscellaneousPerformer
#pragma mark *** Public Methods ***
+ (WCMiscellaneousPerformer *)sharedPerformer; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}
#pragma mark Properties
@dynamic applicationSupportDirectoryURL;
- (NSURL *)applicationSupportDirectoryURL; {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	if (![paths count]) {
		NSLog(@"Unable to locate Application Support directory. Something is really screwed up.");
		return nil;
	}
	
	// create a URL with the name of the application added at the end
	NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	NSURL *directoryURL = [[NSURL fileURLWithPath:[paths objectAtIndex:0]] URLByAppendingPathComponent:applicationName isDirectory:YES];
	
	// it doesn't exist, we need to create it
	if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
		if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"Unable to create Application Support directory for %@.",[[NSProcessInfo processInfo] processName]);
			return nil;
		}
	}
	return directoryURL;
}

@dynamic applicationFontAndColorThemesDirectoryURL;
- (NSURL *)applicationFontAndColorThemesDirectoryURL; {
	return [[NSBundle mainBundle] URLForResource:@"FontAndColorThemes" withExtension:@""];
}
@dynamic userFontAndColorThemesDirectoryURL;
- (NSURL *)userFontAndColorThemesDirectoryURL; {
	NSURL *appSupportURL = [self applicationSupportDirectoryURL];
	if (!appSupportURL)
		return nil;
	
	NSURL *directoryURL = [appSupportURL URLByAppendingPathComponent:NSLocalizedString(@"FontAndColorThemes", @"FontAndColorThemes") isDirectory:YES];
	
	// it doesn't exist, we need to create it
	if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
		if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"Unable to create \"%@\" directory for %@.",[directoryURL lastPathComponent],[[NSProcessInfo processInfo] processName]);
			return nil;
		}
	}
	return directoryURL;
}
@dynamic userKeyBindingCommandSetsDirectoryURL;
- (NSURL *)userKeyBindingCommandSetsDirectoryURL; {
	NSURL *appSupportURL = [self applicationSupportDirectoryURL];
	if (!appSupportURL)
		return nil;
	
	NSURL *directoryURL = [appSupportURL URLByAppendingPathComponent:NSLocalizedString(@"KeyBindingCommandSets", @"KeyBindingCommandSets") isDirectory:YES];
	
	// it doesn't exist, we need to create it
	if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
		if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"Unable to create \"%@\" directory for %@.",[directoryURL lastPathComponent],[[NSProcessInfo processInfo] processName]);
			return nil;
		}
	}
	return directoryURL;
}

@dynamic applicationProjectTemplatesDirectoryURL;
- (NSURL *)applicationProjectTemplatesDirectoryURL {
	return [[NSBundle mainBundle] URLForResource:@"Project Templates" withExtension:@""];
}
@dynamic userProjectTemplatesDirectoryURL;
- (NSURL *)userProjectTemplatesDirectoryURL {
	NSURL *appSupportURL = [self applicationSupportDirectoryURL];
	if (!appSupportURL)
		return nil;
	
	NSURL *directoryURL = [appSupportURL URLByAppendingPathComponent:NSLocalizedString(@"Project Templates", @"Project Templates") isDirectory:YES];
	
	// it doesn't exist, we need to create it
	if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
		if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"Unable to create \"%@\" directory for %@.",[directoryURL lastPathComponent],[[NSProcessInfo processInfo] processName]);
			return nil;
		}
	}
	return directoryURL;
}

@dynamic applicationFileTemplatesDirectoryURL;
- (NSURL *)applicationFileTemplatesDirectoryURL {
	return [[NSBundle mainBundle] URLForResource:@"File Templates" withExtension:@""];
}
@dynamic userFileTemplatesDirectoryURL;
- (NSURL *)userFileTemplatesDirectoryURL {
	NSURL *appSupportURL = [self applicationSupportDirectoryURL];
	if (!appSupportURL)
		return nil;
	
	NSURL *directoryURL = [appSupportURL URLByAppendingPathComponent:NSLocalizedString(@"File Templates", @"File Templates") isDirectory:YES];
	
	// it doesn't exist, we need to create it
	if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
		if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"Unable to create \"%@\" directory for %@.",[directoryURL lastPathComponent],[[NSProcessInfo processInfo] processName]);
			return nil;
		}
	}
	return directoryURL;
}

@dynamic applicationIncludeFilesDirectoryURL;
- (NSURL *)applicationIncludeFilesDirectoryURL {
	return [[NSBundle mainBundle] URLForResource:@"Include Files" withExtension:@""];
}
@end
