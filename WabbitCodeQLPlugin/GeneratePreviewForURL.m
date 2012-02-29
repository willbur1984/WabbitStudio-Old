#include <Cocoa/Cocoa.h>
#include <QuickLook/QuickLook.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSStringEncoding stringEncoding;
	NSString *string = [NSString stringWithContentsOfURL:(NSURL *)url usedEncoding:&stringEncoding error:NULL];
	
	if (!string) {
		[pool release];
		return noErr;
	}
	
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:string attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont userFixedPitchFontOfSize:11.0],NSFontAttributeName, nil]] autorelease];
	
	static NSRegularExpression *commentRegex;
	static NSRegularExpression *operationalCodeRegex;
	static NSRegularExpression *registerRegex;
	static NSRegularExpression *directiveRegex;
	static NSRegularExpression *conditionalRegisterRegex;
	static NSRegularExpression *stringRegex;
	static NSRegularExpression *multilineCommentRegex;
	static NSRegularExpression *numberRegex;
	static NSRegularExpression *binaryNumberRegex;
	static NSRegularExpression *hexadecimalNumberRegex;
	static NSRegularExpression *preProcessorRegex;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		commentRegex = [[NSRegularExpression alloc] initWithPattern:@";+.*" options:0 error:NULL];
		operationalCodeRegex = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:adc|add|and|bit|call|ccf|cpdr|cpd|cpir|cpi|cpl|cp|daa|dec|di|djnz|ei|exx|ex|halt|im|inc|indr|ind|inir|ini|in|jp|jr|lddr|ldd|ldir|ldi|ld|neg|nop|or|otdr|otir|outd|outi|out|pop|push|res|reti|retn|ret|rla|rlca|rlc|rld|rl|rra|rrca|rrc|rrd|rr|rst|sbc|scf|set|sla|sll|sra|srl|sub|xor)\\b" options:NSRegularExpressionAnchorsMatchLines error:NULL];
		registerRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:\\baf')|(?:\\b(?:ixh|iyh|ixl|iyl|sp|af|pc|bc|de|hl|ix|iy|a|f|b|c|d|e|h|l|r|i)\\b)" options:0 error:NULL];
		directiveRegex = [[NSRegularExpression alloc] initWithPattern:@"\\.(?:db|dw|end|org|byte|word|fill|block|addinstr|echo|error|list|nolist|equ|show|option|seek)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
		conditionalRegisterRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:call|jp|jr|ret)\\s+(nz|nv|nc|po|pe|c|p|m|n|z|v)\\b" options:0 error:NULL];
		stringRegex = [[NSRegularExpression alloc] initWithPattern:@"\".*?\"" options:0 error:NULL];
		multilineCommentRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:#comment.*?#endcomment)" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
		numberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:^|(?<=[^$%]\\b))[0-9]+\\b" options:0 error:NULL];
		binaryNumberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:%[01]+\\b)|(?:(?:^|(?<=[^$%]\\b))[01]+(?:b|B)\\b)" options:0 error:NULL];
		hexadecimalNumberRegex = [[NSRegularExpression alloc] initWithPattern:@"(?:\\$[A-Fa-f0-9]+\\b)|(?:(?:^|(?<=[^$%]\\b))[0-9a-fA-F]+(?:h|H)\\b)" options:0 error:NULL];
		preProcessorRegex = [[NSRegularExpression alloc] initWithPattern:@"#(?:define|defcont|elif|else|endif|endmacro|if|ifdef|ifndef|import|include|macro|undef|undefine)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
	});
	
	NSRange range = NSMakeRange(0, [attributedString length]);
	// registers
	[registerRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:[result range]];
	}];
	// conditional registers
	[conditionalRegisterRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor cyanColor] range:[result range]];
	}];
	// operational codes
	[operationalCodeRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:[result range]];
	}];
	// directives
	[directiveRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:[result range]];
	}];
	// numbers
	[numberRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:[result range]];
	}];
	// binary numbers
	[binaryNumberRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:1.0 alpha:1.0] range:[result range]];
	}];
	// hexadecimal numbers
	[hexadecimalNumberRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor magentaColor] range:[result range]];
	}];
	// preprocessor
	[preProcessorRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:[result range]];
	}];
	// strings
	[stringRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor purpleColor] range:[result range]];
	}];
	// comments
	[commentRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0] range:[result range]];
	}];
	[multilineCommentRegex enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0] range:[result range]];
	}];
	
	if (QLPreviewRequestIsCancelled(preview)) {
		[pool release];
		return noErr;
	}
	
	NSData *data = [attributedString dataFromRange:range documentAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NSRTFTextDocumentType,NSDocumentTypeDocumentAttribute,[NSNumber numberWithUnsignedInteger:stringEncoding],NSCharacterEncodingDocumentAttribute, nil] error:NULL];
	
	QLPreviewRequestSetDataRepresentation(preview, (CFDataRef)data, kUTTypeRTF, NULL);
	
	[pool release];
	
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
