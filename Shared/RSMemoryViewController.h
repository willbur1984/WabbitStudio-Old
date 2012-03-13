//
//  RSMemoryViewController.h
//  WabbitStudio
//
//  Created by William Towe on 3/12/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"

@class RSCalculator,PSMTabBarControl;

@interface RSMemoryViewController : JAViewController {
	RSCalculator *_calculator;
	NSMutableSet *_memoryViews;
}
@property (readwrite,assign,nonatomic) IBOutlet PSMTabBarControl *tabBarControl;

@property (readonly,nonatomic) RSCalculator *calculator;

- (id)initWithCalculator:(RSCalculator *)calculator;

- (IBAction)jumpToAddress:(id)sender;
- (IBAction)jumpToProgramCounter:(id)sender;

@end
