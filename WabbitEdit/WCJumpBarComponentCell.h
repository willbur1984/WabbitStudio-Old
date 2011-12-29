//
//  WCJumpBarComponentCell.h
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSPathComponentCell.h>

@class RSVerticallyCenteredTextFieldCell;

@interface WCJumpBarComponentCell : NSPathComponentCell <NSCopying> {
	RSVerticallyCenteredTextFieldCell *_titleCell;
}
@end
