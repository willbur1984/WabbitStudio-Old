//
//  WCSearchResult.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCSearchResult.h"

@implementation WCSearchResult
- (void)dealloc {
	[_string release];
	[_attributedString release];
	[_tokenOrSymbol release];
	[_icon release];
	[super dealloc];
}

+ (WCSearchResult *)searchResultWithRange:(NSRange)range string:(NSString *)string attributedString:(NSAttributedString *)attributedString tokenOrSymbol:(id)tokenOrSymbol; {
	return [[[[self class] alloc] initWithRange:range string:string attributedString:attributedString tokenOrSymbol:tokenOrSymbol] autorelease];
}
- (id)initWithRange:(NSRange)range string:(NSString *)string attributedString:(NSAttributedString *)attributedString tokenOrSymbol:(id)tokenOrSymbol; {
		if (!(self = [super init]))
			return nil;
	
	_range = range;
	_string = [string copy];
	_attributedString = [attributedString copy];
	_tokenOrSymbol = [tokenOrSymbol retain];
	
	return self;
}

@synthesize range=_range;
@synthesize string=_string;
@synthesize attributedString=_attributedString;
@synthesize tokenOrSymbol=_tokenOrSymbol;

@end
