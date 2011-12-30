//
//  RSFindSearchField.h
//  WabbitEdit
//
//  Created by William Towe on 12/30/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSSearchField.h>

@class RSFindBarViewController;

@interface RSFindSearchField : NSSearchField
@property (readwrite,assign,nonatomic) IBOutlet RSFindBarViewController *findBarViewController;
@end
