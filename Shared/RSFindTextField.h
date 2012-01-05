//
//  RSFindTextField.h
//  WabbitEdit
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextField.h>

@class RSFindBarViewController;

@interface RSFindTextField : NSTextField
@property (readwrite,assign,nonatomic) IBOutlet RSFindBarViewController *findBarViewController;
@end
