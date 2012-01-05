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

@interface RSFindSearchFieldCell ()
+ (RSFindBarFieldEditor *)fieldEditor;
@end

@implementation RSFindSearchFieldCell
- (NSTextView *)fieldEditorForView:(NSView *)aControlView {
	if ([aControlView isKindOfClass:[RSFindSearchField class]])
		[[[self class] fieldEditor] setFindTextView:[[(RSFindSearchField *)aControlView findBarViewController] textView]];
	
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
