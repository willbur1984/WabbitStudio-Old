//
//  RSGifRecordingStatusView.h
//  WabbitStudio
//
//  Created by William Towe on 2/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSView.h>

@class RSVerticallyCenteredTextFieldCell;

@interface RSGifRecordingStatusView : NSView {
	RSVerticallyCenteredTextFieldCell *_textFieldCell;
	NSString *_statusString;
}
@property (readwrite,copy,nonatomic) NSString *statusString;
@end
