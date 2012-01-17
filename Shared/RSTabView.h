//
//  RSTabView.h
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTabView.h>
#import "RSEmptyContentCell.h"

@interface RSTabView : NSTabView {
	RSEmptyContentCell *_emptyContentStringCell;
}
@property (readonly,nonatomic) NSString *emptyContentString;
@property (readonly,nonatomic) BOOL shouldDrawEmptyContentString;
@property (readonly,nonatomic) RSEmptyContentStringStyle emptyContentStringStyle;
@end
