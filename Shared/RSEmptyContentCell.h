//
//  RSEmptyContentCell.h
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextFieldCell.h>

typedef enum _RSEmptyContentStringStyle {
	RSEmptyContentStringStyleNormal,
	RSEmptyContentStringStyleSourceList
	
} RSEmptyContentStringStyle;

@interface RSEmptyContentCell : NSTextFieldCell {
    RSEmptyContentStringStyle _emptyContentStringStyle;
}
@property (readwrite,assign,nonatomic) RSEmptyContentStringStyle emptyContentStringStyle;
@end
