//
//  WCDebugController.m
//  WabbitStudio
//
//  Created by William Towe on 2/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCDebugController.h"
#import "RSCalculator.h"
#import "RSTransferFileWindowController.h"'
#import "WCFile.h"

NSString *const WCDebugControllerDebugSessionDidBeginNotification = @"WCDebugControllerDebugSessionDidBeginNotification";
NSString *const WCDebugControllerDebugSessionDidEndNotification = @"WCDebugControllerDebugSessionDidEndNotification";
NSString *const WCDebugControllerCurrentFileDidChangeNotification = @"WCDebugControllerCurrentFileDidChangeNotification";
NSString *const WCDebugControllerCurrentLineNumberDidChangeNotification = @"WCDebugControllerCurrentLineNumberDidChangeNotification";

@implementation WCDebugController
- (void)dealloc {
	_projectDocument = nil;
	[_calculator release];
	[_codeListing release];
	[_labelFile release];
	[_currentFile release];
	[super dealloc];
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super init]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

+ (NSGradient *)debugFillGradient; {
	static NSGradient *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:0.05] endingColor:[NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:0.3]];
	});
	return retval;
}
+ (NSColor *)debugFillColor; {
	return [NSColor colorWithCalibratedRed:0.0 green:0.75 blue:0.0 alpha:1.0];
}

@synthesize projectDocument=_projectDocument;
@dynamic calculator;
- (RSCalculator *)calculator {
	if (!_calculator) {
		_calculator = [[RSCalculator alloc] initWithRomOrSavestateURL:nil error:NULL];
		[_calculator setDelegate:self];
	}
	return _calculator;
}
@synthesize codeListing=_codeListing;
@synthesize labelFile=_labelFile;
@synthesize currentFile=_currentFile;
@synthesize currentLineNumber=_currentLineNumber;
@dynamic debugging;
- (BOOL)isDebugging {
	return _debugFlags.debugging;
}
- (void)setDebugging:(BOOL)debugging {
	_debugFlags.debugging = debugging;
}

@end
