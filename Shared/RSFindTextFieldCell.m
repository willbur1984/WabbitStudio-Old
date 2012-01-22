//
//  RSFindTextFieldCell.m
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSFindTextFieldCell.h"
#import "RSFindBarFieldEditor.h"
#import "RSFindBarViewController.h"
#import "RSFindTextField.h"

@implementation RSFindTextFieldCell
- (NSTextView *)fieldEditorForView:(NSView *)aControlView {
	if ([aControlView isKindOfClass:[RSFindTextField class]])
		[[RSFindBarFieldEditor sharedInstance] setFindTextView:[[(RSFindTextField *)aControlView findBarViewController] textView]];
	
	return [RSFindBarFieldEditor sharedInstance];
}
@end
