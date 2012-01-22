//
//  RSFindSearchFieldCell.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFindSearchFieldCell.h"
#import "RSFindBarFieldEditor.h"
#import "RSFindBarViewController.h"
#import "RSFindSearchField.h"

@implementation RSFindSearchFieldCell
#pragma mark *** Subclass Overrides ***
- (NSTextView *)fieldEditorForView:(NSView *)aControlView {
	if ([aControlView isKindOfClass:[RSFindSearchField class]])
		[[RSFindBarFieldEditor sharedInstance] setFindTextView:[[(RSFindSearchField *)aControlView findBarViewController] textView]];
	
	return [RSFindBarFieldEditor sharedInstance];
}
@end
