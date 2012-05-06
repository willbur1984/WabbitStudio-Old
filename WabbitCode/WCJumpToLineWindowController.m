//
//  WCJumpToLineWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCJumpToLineWindowController.h"
#import "NSString+RSExtensions.h"

@interface WCJumpToLineWindowController ()
@property (readwrite,assign,nonatomic) NSTextView *textView;
@end

@implementation WCJumpToLineWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_jumpMode = WCJumpToLineWindowControllerJumpModeLine;
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCJumpToLineWindow";
}
#pragma mark *** Public Methods ***
+ (WCJumpToLineWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] init];
	});
	return sharedInstance;
}

- (void)showJumpToLineWindowForTextView:(NSTextView *)textView; {
	[self setTextView:textView];
	
	switch ([self jumpMode]) {
		case WCJumpToLineWindowControllerJumpModeCharacter:
			[self setCharacterOrLineString:[NSString stringWithFormat:@"%lu",[[self textView] selectedRange].location]];
			break;
		case WCJumpToLineWindowControllerJumpModeLine:
			[self setCharacterOrLineString:[NSString stringWithFormat:@"%lu",[[[self textView] string] lineNumberForRange:[[self textView] selectedRange]]+1]];
			break;
		default:
			break;
	}
	
	NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
	
	if (result == NSOKButton) {
		NSString *string = [[self characterOrLineString] stringByRemovingInvalidDigits];
		NSUInteger value = [string valueFromString];
		NSRange range;
		
		switch ([self jumpMode]) {
			case WCJumpToLineWindowControllerJumpModeCharacter:
				if (value >= [[[self textView] string] length])
					value = [[[self textView] string] length] - 1;
				
				range = NSMakeRange(value, 0);
				break;
			case WCJumpToLineWindowControllerJumpModeLine: {
				NSUInteger numberOfLines = [[[self textView] string] numberOfLines];
				if (value > numberOfLines)
					value = numberOfLines - 1;
				else if (value > 0)
					value--;
				
				range = NSMakeRange([[[self textView] string] rangeForLineNumber:value].location, 0);
			}
				break;
			default:
				break;
		}
		
		[[self textView] setSelectedRange:range];
		[[self textView] centerSelectionInVisibleArea:nil];
	}
	
	[self setTextView:nil];
}
#pragma mark IBActions
- (IBAction)jump:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
	[[self window] orderOut:nil];
}
- (IBAction)cancel:(id)sender; {
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
	[[self window] orderOut:nil];
}
#pragma mark Properties
@synthesize jumpMode=_jumpMode;
@synthesize characterOrLineString=_characterOrLineString;
@synthesize textView=_textView;

@end
