//
//  RSTableViewDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/25/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class RSTableView;

@protocol RSTableViewDelegate <NSTableViewDelegate>
@optional
- (void)handleDeletePressedForTableView:(RSTableView *)tableView;
- (void)handleReturnPressedForTableView:(RSTableView *)tableView;
- (void)handleSpacePressedForTableView:(RSTableView *)tableView;
@end
