//
//  WCSearchResult.m
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSearchResult.h"

@implementation WCSearchResult
- (void)dealloc {
	[_string release];
	[_attributedString release];
	[_tokenOrSymbol release];
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
