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
#import "WCScanFoldsOperation.h"
#import "NDTrie.h"

NSString *const WCSourceScannerDidFinishScanningNotification = @"WCSourceScannerDidFinishScanningNotification";
NSString *const WCSourceScannerDidFinishScanningSymbolsNotification = @"WCSourceScannerDidFinishScanningSymbolsNotification";
NSString *const WCSourceScannerDidFinishScanningFoldsNotification = @"WCSourceScannerDidFinishScanningFoldsNotification";

@interface WCSourceScanner ()

@end

@implementation WCSourceScanner
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_scanTimer invalidate];
	_textStorage = nil;
	[_operationQueue release];
	[_tokens release];
	[_symbols release];
	[_symbolsSortedByName release];
	[_macros release];
	[_labelNamesToLabelSymbols release];
	[_equateNamesToEquateSymbols release];
	[_defineNamesToDefineSymbols release];
	[_macroNamesToMacroSymbols release];
	[_completions release];
	[_includes release];
	[_folds release];
	[_calledLabels release];
	[super dealloc];
}
#pragma mark *** Public Methods ***
- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
	if (!(self = [super init]))
		return nil;
	
	_textStorage = textStorage;
	_operationQueue = [[NSOperationQueue alloc] init];
	[_operationQueue setMaxConcurrentOperationCount:2];
	_tokens = [[NSArray alloc] init];
	_symbols = [[NSArray alloc] init];
	_labelNamesToLabelSymbols = [[NSDictionary alloc] init];
	_symbolsSortedByName = [[NSArray alloc] init];
	_equateNamesToEquateSymbols = [[NSDictionary alloc] init];
	_defineNamesToDefineSymbols = [[NSDictionary alloc] init];
	_macroNamesToMacroSymbols = [[NSDictionary alloc] init];
	_includes = [[NSSet alloc] init];
	_folds = [[NSArray alloc] init];
	_calledLabels = [[NSSet alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
	
	return self;
}

- (void)scanTokens; {
	[_scanTimer invalidate];
	_scanTimer = nil;
	
	[_operationQueue cancelAllOperations];
	
	if ([self needsToScanSymbols]) {
		NSOperation *scanTokensOperation = [WCScanTokensOperation scanTokensOperationWithScanner:self];
		NSOperation *scanSymbolsOperation = [WCScanSymbolsOperation scanSymbolsOperationWithSourceScanner:self];
		NSOperation *scanFoldsOperation = [WCScanFoldsOperation scanFoldsOperationWithSourceScanner:self];
		
		[scanSymbolsOperation addDependency:scanTokensOperation];
		[scanFoldsOperation addDependency:scanTokensOperation];
		
		[_operationQueue setSuspended:YES];
		[_operationQueue addOperation:scanTokensOperation];
		[_operationQueue addOperation:scanFoldsOperation];
		[_operationQueue addOperation:scanSymbolsOperation];
		[_operationQueue setSuspended:NO];
	}
	else {
		NSOperation *scanTokensOperation = [WCScanTokensOperation scanTokensOperationWithScanner:self];
		NSOperation *scanFoldsOperation = [WCScanFoldsOperation scanFoldsOperationWithSourceScanner:self];
		
		[scanFoldsOperation addDependency:scanTokensOperation];
		
		[_operationQueue setSuspended:YES];
		[_operationQueue addOperation:scanTokensOperation];
		[_operationQueue addOperation:scanFoldsOperation];
		[_operationQueue setSuspended:NO];
	}
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
		//retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#comment.*?#endcomment)|(?:#comment.*)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#comment.*?#endcomment)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)mnemonicRegularExpression {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:adc|add|and|bit|call|ccf|cpdr|cpd|cpir|cpi|cpl|cp|daa|dec|di|djnz|ei|exx|ex|halt|im|inc|indr|ind|inir|ini|in|jp|jr|lddr|ldd|ldir|ldi|ld|neg|nop|or|otdr|otir|outd|outi|out|pop|push|res|reti|retn|ret|rla|rlca|rlc|rld|rl|rra|rrca|rrc|rrd|rr|rst|sbc|scf|set|sla|sll|sra|srl|sub|xor)\\b" options:NSRegularExpressionAnchorsMatchLines error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)registerRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:\\baf')|(?:\\b(?:ixh|iyh|ixl|iyl|sp|af|pc|bc|de|hl|ix|iy|a|f|b|c|d|e|h|l|r|i)\\b)" options:0 error:NULL];
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
+ (NSRegularExpression *)includesRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#include|#import)\\s+\"(.*?)\"" options:NSRegularExpressionCaseInsensitive error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)calledLabelRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:call|jp|jr)\\s+([A-Za-z0-9_!?]+)\\b" options:0 error:NULL];
	});
	return retval;
}
+ (NSRegularExpression *)calledLabelWithConditionalRegularExpression; {
	static NSRegularExpression *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:call|jp|jr)\\s+(?:nz|nv|nc|po|pe|c|p|m|n|z|v),\\s*([A-Za-z0-9_!?]+)\\b" options:0 error:NULL];
	});
	return retval;
}
#pragma mark Properties
@synthesize delegate=_delegate;
@synthesize textStorage=_textStorage;
@synthesize tokens=_tokens;
@synthesize symbols=_symbols;
@synthesize symbolsSortedByName=_symbolsSortedByName;
@synthesize macros=_macros;
@synthesize needsToScanSymbols=_needsToScanSymbols;
@synthesize labelNamesToLabelSymbols=_labelNamesToLabelSymbols;
@synthesize equateNamesToEquateSymbols=_equateNamesToEquateSymbols;
@synthesize defineNamesToDefineSymbols=_defineNamesToDefineSymbols;
@synthesize macroNamesToMacroSymbols=_macroNamesToMacroSymbols;
@synthesize completions=_completions;
@synthesize includes=_includes;
@synthesize folds=_folds;
@synthesize calledLabels=_calledLabels;
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_textStorageDidProcessEditing:(NSNotification *)note {
	if (([[note object] editedMask] & NSTextStorageEditedCharacters) == 0)
		return;
	
	if (_scanTimer)
		[_scanTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.35]];
	else
		_scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(scanTokens) userInfo:nil repeats:NO];
}

@end
