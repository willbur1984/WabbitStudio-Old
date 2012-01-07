//
//  WCJumpToLineWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

typedef enum _WCJumpToLineWindowControllerJumpMode {
	WCJumpToLineWindowControllerJumpModeCharacter = 0,
	WCJumpToLineWindowControllerJumpModeLine = 1
	
} WCJumpToLineWindowControllerJumpMode;

@interface WCJumpToLineWindowController : NSWindowController {
	__weak NSTextView *_textView;
	WCJumpToLineWindowControllerJumpMode _jumpMode;
	NSString *_characterOrLineString;
}
@property (readwrite,copy,nonatomic) NSString *characterOrLineString;
@property (readwrite,assign,nonatomic) WCJumpToLineWindowControllerJumpMode jumpMode;

+ (WCJumpToLineWindowController *)sharedWindowController;

- (void)showJumpToLineWindowForTextView:(NSTextView *)textView;

- (IBAction)jump:(id)sender;
- (IBAction)cancel:(id)sender;
@end
