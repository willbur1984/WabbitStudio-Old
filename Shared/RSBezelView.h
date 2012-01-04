//
//  RSBezelView.h
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSView.h>

@interface RSBezelView : NSView {
	NSImage *_image;
	NSTextFieldCell *_stringCell;
}
@property (readwrite,retain,nonatomic) NSImage *image;
@property (readwrite,copy,nonatomic) NSString *string;
@end
