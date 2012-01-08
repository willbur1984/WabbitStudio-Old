//
//  WCSourceScanner.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import "WCSourceScanner.h"
#import "WCScanTokensOperation.h"
#import "WCScanSymbolsOperation.h"
#import "WCSourceSymbol.h"
#import "NDTrie.h"

NSString *const WCSourceScannerDidFinishScanningNotification = @"WCSourceScannerDidFinishScanningNotification";
NSString *const WCSourceScannerDidFinishScanningSymbolsNotification = @"WCSourceScannerDidFinishScanningSymbolsNotification";

@implementation WCSourceScanner
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_textStorage = nil;
	[_operationQueue release];
	[_tokens release];
	[_symbols release];
	[_symbolsSortedByName release];
	[_labelNamesToLabelSymbols release];
	[_equateNamesToEquateSymbols release];
	[_defineNamesToDefineSymbols release];
	[_macroNamesToMacroSymbols release];
	[_completions release];
	[super dealloc];
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
	if (!(self = [super init]))
		return nil;
	
	_textStorage = textStorage;
	_operationQueue = [[NSOperationQueue alloc] init];
	[_operationQueue setMaxConcurrentOperationCount:1];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
	
	return self;
}

- (void)scanTokens; {
	[_operationQueue cancelAllOperations];
	[_operationQueue addOperation:[WCScanTokensOperation scanTokensOperationWithScanner:self]];
}

+ (NSRegularExpression *)commentRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@";+.*" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)multilineCommentRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#comment.*?#endcomment)|(?:#comment.*)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)mnemonicRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:adc|add|and|bit|call|ccf|cpdr|cpd|cpir|cpi|cpl|cp|daa|dec|di|djnz|ei|exx|ex|halt|im|inc|indr|ind|inir|ini|in|jp|jr|lddr|ldd|ldir|ldi|ld|neg|nop|or|otdr|otir|outd|outi|out|pop|push|res|reti|retn|ret|rla|rlca|rlc|rld|rl|rra|rrca|rrc|rrd|rr|rst|sbc|scf|set|sla|sll|sra|srl|sub|xor)\\b" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)registerRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(ixh|iyh|ixl|iyl|sp|af'|af|pc|bc|de|hl|ix|iy|a|f|b|c|d|e|h|l|r|i)\\b" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)directiveRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\.(?:db|dw|end|org|byte|word|fill|block|addinstr|echo|error|list|nolist|equ|show|option|seek)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)numberRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:^|(?<=[^$%]\\b))[0-9]+\\b" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)binaryRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:%[01]+\\b)|(?:(?:^|(?<=[^$%]\\b))[01]+(?:b|B)\\b)" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)hexadecimalRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:\\$[A-Fa-f0-9]+\\b)|(?:(?:^|(?<=[^$%]\\b))[0-9a-fA-F]+(?:h|H)\\b)" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)preProcessorRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"#(?:comment|define|defcont|elif|else|endif|endmacro|if|ifdef|ifndef|import|include|macro|undef|undefine)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)stringRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\".*?\"" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)labelRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z0-9_!?]+" options:NSRegularExpressionAnchorsMatchLines error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)equateRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"^([A-Za-z0-9_!?]+)(?:(?:\\s*=)|(?:\\s+\\.(?:equ|EQU))|(?:\\s+(?:equ|EQU)))" options:NSRegularExpressionAnchorsMatchLines error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)conditionalRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:call|jp|jr|ret)\\s+(nz|nv|nc|po|pe|c|p|m|n|z|v)\\b" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)defineRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#define|DEFINE)\\s+([A-Za-z0-9_.!?]+)" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)macroRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#macro|MACRO)\\s+([A-Za-z0-9_.!?]+)" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)symbolRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z0-9_!?.]+" options:0 error:NULL];
	});
	return retval;
}

@synthesize delegate=_delegate;
@synthesize textStorage=_textStorage;
@synthesize tokens=_tokens;
@synthesize symbols=_symbols;
@synthesize symbolsSortedByName=_symbolsSortedByName;

@dynamic needsToScanSymbols;
- (BOOL)needsToScanSymbols {
	return _needsToScanSymbols;
}
- (void)setNeedsToScanSymbols:(BOOL)needsToScanSymbols {
	_needsToScanSymbols = needsToScanSymbols;
	
	if (_needsToScanSymbols) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sourceScannerDidFinishScanning:) name:WCSourceScannerDidFinishScanningNotification object:self];
	}
	else {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:WCSourceScannerDidFinishScanningNotification object:nil];
	}
}

@synthesize labelNamesToLabelSymbols=_labelNamesToLabelSymbols;
@synthesize equateNamesToEquateSymbols=_equateNamesToEquateSymbols;
@synthesize defineNamesToDefineSymbols=_defineNamesToDefineSymbols;
@synthesize macroNamesToMacroSymbols=_macroNamesToMacroSymbols;
@synthesize completions=_completions;

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	
	if (_tokenScanningTimer)
		[_tokenScanningTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
	else
		_tokenScanningTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_tokenScanningTimerCallback:) userInfo:nil repeats:NO];
}

- (void)_sourceScannerDidFinishScanning:(NSNotification *)note {
	[_operationQueue cancelAllOperations];
	[_operationQueue addOperation:[WCScanSymbolsOperation scanSymbolsOperationWithSourceScanner:self]];
}

- (void)_tokenScanningTimerCallback:(NSTimer *)timer {
	[_tokenScanningTimer invalidate];
	_tokenScanningTimer = nil;
	
	[self scanTokens];
}
@end
