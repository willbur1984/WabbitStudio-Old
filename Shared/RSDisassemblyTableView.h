//
//  RSDisassemblyTableView.h
//  WabbitStudio
//
//  Created by William Towe on 3/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTableView.h"

@class RSDisassemblyViewController;

@interface RSDisassemblyTableView : RSTableView 
@property (readwrite,assign,nonatomic) IBOutlet RSDisassemblyViewController *disassemblyViewController;
@end
