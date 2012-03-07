//
//  RSDisassemblyAddressFormatter.m
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSDisassemblyAddressFormatter.h"

@interface RSDisassemblyAddressFormatter ()
- (void)_commonInit;
@end

@implementation RSDisassemblyAddressFormatter
- (id)init {
	if (!(self = [super init]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	[self _commonInit];
	
	return self;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)defaultAttributes {
	NSString *string = [self stringForObjectValue:obj];
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:string attributes:defaultAttributes] autorelease];
	
	[attributedString applyFontTraits:NSBoldFontMask range:NSMakeRange(0, [attributedString length])];
	
	return attributedString;
}

- (void)_commonInit; {
	[self setHexadecimalFormat:RSHexadecimalFormatUppercaseUnsignedShort];
}
@end
