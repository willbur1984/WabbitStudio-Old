//
//  RSFindBarFieldEditor.h
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>

@interface RSFindBarFieldEditor : NSTextView {
	__weak NSTextView *_findTextView;
}
@property (readwrite,assign,nonatomic) NSTextView *findTextView;
@end
