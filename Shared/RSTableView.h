//
//  RSTableView.h
//  WabbitEdit
//
//  Created by William Towe on 7/8/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableView.h>
#import "RSEmptyContentCell.h"
#import "RSTableViewDelegate.h"

@protocol RSTableViewDelegate;

@interface RSTableView : NSTableView {
    RSEmptyContentCell *_emptyContentStringCell;
}
@property (readwrite,assign,nonatomic) IBOutlet id <RSTableViewDelegate> delegate;
@property (readonly,nonatomic) NSString *emptyContentString;
@property (readonly,nonatomic) BOOL shouldDrawEmptyContentString;
@property (readonly,nonatomic) RSEmptyContentStringStyle emptyContentStringStyle;
@end
