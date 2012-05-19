//
//  WCSourceScanner.h
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/NSObject.h>
#import "WCSourceScannerDelegate.h"

extern NSString *const WCSourceScannerDidFinishScanningNotification;
extern NSString *const WCSourceScannerDidFinishScanningSymbolsNotification;
extern NSString *const WCSourceScannerDidFinishScanningFoldsNotification;

@class NDTrie;

@interface WCSourceScanner : NSObject {
	__weak NSTextStorage *_textStorage;
	__weak id <WCSourceScannerDelegate> _delegate;
	NSOperationQueue *_operationQueue;
	NSTimer *_scanTimer;
	NSArray *_tokens;
	BOOL _needsToScanSymbols;
	NSArray *_symbols;
	NSArray *_symbolsSortedByName;
	NSArray *_macros;
	NSDictionary *_labelNamesToLabelSymbols;
	NSDictionary *_equateNamesToEquateSymbols;
	NSDictionary *_defineNamesToDefineSymbols;
	NSDictionary *_macroNamesToMacroSymbols;
	NDTrie *_completions;
	NSSet *_includes;
	NSArray *_folds;
	NSSet *_calledLabels;
}
@property (readwrite,assign,nonatomic) id <WCSourceScannerDelegate> delegate;
@property (readonly,nonatomic) NSTextStorage *textStorage;
@property (readwrite,copy) NSArray *tokens;
@property (readwrite,assign,nonatomic) BOOL needsToScanSymbols;
@property (readwrite,copy) NSArray *symbols;
@property (readwrite,copy) NSArray *symbolsSortedByName;
@property (readwrite,copy) NSArray *macros;
@property (readwrite,copy) NSDictionary *labelNamesToLabelSymbols;
@property (readwrite,copy) NSDictionary *equateNamesToEquateSymbols;
@property (readwrite,copy) NSDictionary *defineNamesToDefineSymbols;
@property (readwrite,copy) NSDictionary *macroNamesToMacroSymbols;
@property (readwrite,copy) NDTrie *completions;
@property (readwrite,copy) NSSet *includes;
@property (readwrite,copy) NSArray *folds;
@property (readwrite,copy) NSSet *calledLabels;

- (id)initWithTextStorage:(NSTextStorage *)textStorage;

- (void)scanTokens;

+ (NSRegularExpression *)commentRegularExpression;
+ (NSRegularExpression *)multilineCommentRegularExpression;
+ (NSRegularExpression *)mnemonicRegularExpression;
+ (NSRegularExpression *)registerRegularExpression;
+ (NSRegularExpression *)directiveRegularExpression;
+ (NSRegularExpression *)numberRegularExpression;
+ (NSRegularExpression *)binaryRegularExpression;
+ (NSRegularExpression *)hexadecimalRegularExpression;
+ (NSRegularExpression *)preProcessorRegularExpression;
+ (NSRegularExpression *)stringRegularExpression;
+ (NSRegularExpression *)labelRegularExpression;
+ (NSRegularExpression *)equateRegularExpression;
+ (NSRegularExpression *)conditionalRegularExpression;
+ (NSRegularExpression *)defineRegularExpression;
+ (NSRegularExpression *)macroRegularExpression;
+ (NSRegularExpression *)symbolRegularExpression;
+ (NSRegularExpression *)includesRegularExpression;
+ (NSRegularExpression *)calledLabelRegularExpression;
+ (NSRegularExpression *)calledLabelWithConditionalRegularExpression;
@end
