//
//  WCRoundedBorderTextFieldCell.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextFieldCell.h>

@class RSVerticallyCenteredTextFieldCell;

@interface WCRoundedBorderTextFieldCell : NSTextFieldCell {
	RSVerticallyCenteredTextFieldCell *_titleCell;
}
@end
