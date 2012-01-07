//
//  WCJumpToLineWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCJumpToLineWindowController.h"
#import "NSString+RSExtensions.h"

@interface WCJumpToLineWindowController ()
@property (readwrite,assign,nonatomic) NSTextView *textView;
@end

@implementation WCJumpToLineWindowController

- (id)init {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_jumpMode = WCJumpToLineWindowControllerJumpModeLine;
	
	return self;
}

- (NSString *)windowNibName {
	return @"WCJumpToLineWindow";
}

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
		[[self textView] scrollRangeToVisible:range];
	}
	
	[self setTextView:nil];
}

- (IBAction)jump:(id)sender; {
	[[self window] close];
	[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
}
- (IBAction)cancel:(id)sender; {
	[[self window] close];
	[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
}

@synthesize jumpMode=_jumpMode;
@synthesize characterOrLineString=_characterOrLineString;
@synthesize textView=_textView;

@end
