//
//  WCFold.m
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFold.h"
#import "WCSourceScanner.h"
#import "WCSourceHighlighter.h"
#import "RSDefines.h"
#import "WCFontAndColorThemeManager.h"

@interface WCFold ()
@property (readwrite,copy,nonatomic) NSAttributedString *attributedString;
@end

@implementation WCFold
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_sourceScanner = nil;
	[_childFoldsSortedByLevelAndLocation release];
	[_attributedString release];
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"range: %@ level: %lu contentRange: %@",NSStringFromRange([self range]),[self level],NSStringFromRange([self contentRange])];
}
#pragma mark RSToolTipProvider
- (NSAttributedString *)attributedToolTip {
	return [self attributedString];
}
#pragma mark *** Public Methods ***
+ (id)foldOfType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange; {
	return [[[[self class] alloc] initWithType:type level:level range:range contentRange:contentRange] autorelease];
}
- (id)initWithType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange; {
	if (!(self = [super initWithRepresentedObject:nil]))
		return nil;
	
	_type = type;
	_level = level;
	_range = range;
	_contentRange = contentRange;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_currentThemeDidChange:) name:WCFontAndColorThemeManagerCurrentThemeDidChangeNotification  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_colorDidChange:) name:WCFontAndColorThemeManagerColorDidChangeNotification object:nil];
	
	return self;
}
#pragma mark Properties
@synthesize sourceScanner=_sourceScanner;
@synthesize type=_type;
@synthesize range=_range;
@synthesize contentRange=_contentRange;
@synthesize level=_level;
- (void)setLevel:(NSUInteger)level {
	_level = level;
	
	for (WCFold *fold in [self childNodes])
		[fold setLevel:level+1];
}
@synthesize attributedString=_attributedString;
- (NSAttributedString *)attributedString {
	if (!_attributedString) {
		NSString *string = [[[[[self sourceScanner] textStorage] string] substringWithRange:[self range]] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		NSMutableAttributedString *temp = [[[NSMutableAttributedString alloc] initWithString:string attributes:RSToolTipProviderDefaultAttributes()] autorelease];
		WCSourceHighlighter *highlighter = [[[self sourceScanner] delegate] sourceHighlighterForSourceScanner:[self sourceScanner]];
		
		[highlighter highlightAttributeString:temp];
		
		_attributedString = [temp copy];
	}
	return _attributedString;
}
@synthesize childFoldsSortedByLevelAndLocation=_childFoldsSortedByLevelAndLocation;
- (NSArray *)childFoldsSortedByLevelAndLocation {
	if (!_childFoldsSortedByLevelAndLocation) {
		NSMutableArray *temp = [NSMutableArray arrayWithArray:[self descendantNodes]];
		
		[temp sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"level" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
			if ([obj1 rangeValue].location < [obj2 rangeValue].location)
				return NSOrderedAscending;
			else if ([obj1 rangeValue].location > [obj2 rangeValue].location)
				return NSOrderedDescending;
			return NSOrderedSame;
		}], nil]];
		
		_childFoldsSortedByLevelAndLocation = [temp copy];
	}
	return _childFoldsSortedByLevelAndLocation;
}
#pragma mark *** Private Methods ***

#pragma mark Notifications
- (void)_currentThemeDidChange:(NSNotification *)note {
	[self setAttributedString:nil];
}
- (void)_colorDidChange:(NSNotification *)note {
	[self setAttributedString:nil];
}
@end
