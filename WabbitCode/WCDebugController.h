//
//  WCDebugController.h
//  WabbitStudio
//
//  Created by William Towe on 2/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "RSCalculatorDelegate.h"
#import "RSTransferFileWindowControllerDelegate.h"

extern NSString *const WCDebugControllerDebugSessionDidBeginNotification;
extern NSString *const WCDebugControllerDebugSessionDidEndNotification;
extern NSString *const WCDebugControllerCurrentFileDidChangeNotification;
extern NSString *const WCDebugControllerCurrentLineNumberDidChangeNotification;

@class WCProjectDocument,RSFileReference,WCFile;

@interface WCDebugController : NSObject <RSCalculatorDelegate,RSTransferFileWindowControllerDelegate> {
	__weak WCProjectDocument *_projectDocument;
	RSFileReference *_romOrSavestateForRunning;
	RSCalculator *_calculator;
	NSString *_codeListing;
	NSString *_labelFile;
	WCFile *_currentFile;
	NSUInteger _currentLineNumber;
	struct {
		unsigned int debugging:1;
		unsigned int runBuildProductAfterRomOrSavestateSheetFinishes:1;
		unsigned int RESERVED:30;
	} _debugFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) RSCalculator *calculator;
@property (readonly,nonatomic) NSString *codeListing;
@property (readonly,nonatomic) NSString *labelFile;
@property (readonly,nonatomic) WCFile *currentFile;
@property (readonly,nonatomic) NSUInteger currentLineNumber;
@property (readonly,nonatomic,getter = isDebugging) BOOL debugging;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

+ (NSGradient *)debugFillGradient;
+ (NSColor *)debugFillColor;

@end
