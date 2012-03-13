//
//  RSRegularMemoryTableView.h
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTableView.h"

@class RSRegularMemoryViewController;

@interface RSRegularMemoryTableView : RSTableView
@property (readwrite,assign,nonatomic) IBOutlet RSRegularMemoryViewController *regularMemoryViewController;
@end
