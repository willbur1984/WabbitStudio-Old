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

@interface RSFindTextFieldCell ()
+ (RSFindBarFieldEditor *)fieldEditor;
@end

@implementation RSFindTextFieldCell
- (NSTextView *)fieldEditorForView:(NSView *)aControlView {
	if ([aControlView isKindOfClass:[RSFindTextField class]])
		[[[self class] fieldEditor] setFindTextView:[[(RSFindTextField *)aControlView findBarViewController] textView]];
	
	return [[self class] fieldEditor];
}

+ (RSFindBarFieldEditor *)fieldEditor; {
	static RSFindBarFieldEditor *retval;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		retval = [[RSFindBarFieldEditor alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
		[retval setFieldEditor:YES];
	});
	return retval;
}
@end
