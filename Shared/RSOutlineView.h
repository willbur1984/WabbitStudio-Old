//
//  RSOutlineView.h
//  WabbitStudio
//
//  Created by William Towe on 7/20/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSOutlineView.h>
#import "RSEmptyContentCell.h"
#import "RSOutlineViewDelegate.h"

@interface RSOutlineView : NSOutlineView <NSUserInterfaceValidations> {
	RSEmptyContentCell *_emptyContentStringCell;
}
@property (readwrite,assign,nonatomic) IBOutlet id <NSOutlineViewDelegate> delegate;
@property (readonly,nonatomic) NSString *emptyContentString;
@property (readonly,nonatomic) BOOL shouldDrawEmptyContentString;
@property (readonly,nonatomic) RSEmptyContentStringStyle emptyContentStringStyle;

@end
