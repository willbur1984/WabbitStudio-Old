//
//  WCDebugController.h
//  WabbitStudio
//
//  Created by William Towe on 2/24/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
		unsigned int buildAfterRomOrSavestateSheetFinishes:1;
		unsigned int RESERVED:29;
	} _debugFlags;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) RSCalculator *calculator;
@property (readonly,copy,nonatomic) NSString *codeListing;
@property (readonly,copy,nonatomic) NSString *labelFile;
@property (readonly,retain,nonatomic) WCFile *currentFile;
@property (readonly,assign,nonatomic) NSUInteger currentLineNumber;
@property (readonly,nonatomic,getter = isDebugging) BOOL debugging;
@property (readonly,retain,nonatomic) RSFileReference *romOrSavestateForRunning;
@property (readwrite,assign,nonatomic) BOOL runBuildProductAfterRomOrSavestateSheetFinishes;
@property (readwrite,assign,nonatomic) BOOL buildAfterRomOrSavestateSheetFinishes;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

+ (NSGradient *)debugFillGradient;
+ (NSColor *)debugFillColor;

- (void)changeRomOrSavestateForRunning;

@end
