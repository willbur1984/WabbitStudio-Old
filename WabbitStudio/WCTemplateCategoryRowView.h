//
//  WCTemplateCategoryRowView.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableRowView.h>

@interface WCTemplateCategoryRowView : NSTableRowView
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *tableView;
@end
