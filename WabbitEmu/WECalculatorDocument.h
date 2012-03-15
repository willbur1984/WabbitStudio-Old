//
//  WECalculatorDocument.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocument.h>
#import "RSCalculatorDelegate.h"

@interface WECalculatorDocument : NSDocument <RSCalculatorDelegate> {
	RSCalculator *_calculator;
}
@property (readonly,retain,nonatomic) RSCalculator *calculator;

- (IBAction)showDebugger:(id)sender;

@end
