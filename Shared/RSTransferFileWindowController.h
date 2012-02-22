//
//  RSTransferFileWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 2/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>
#import "RSTransferFileWindowControllerDelegate.h"

@class RSCalculator,RSTransferFile;

@interface RSTransferFileWindowController : NSWindowController {
	__weak id <RSTransferFileWindowControllerDelegate> _delegate;
	RSCalculator *_calculator;
	NSMutableArray *_romsAndSavestates;
	NSMutableArray *_otherFiles;
	NSString *_statusString;
	CGFloat _totalSize;
	CGFloat _currentProgress;
	RSTransferFile *_currentTransferFile;
}
@property (readwrite,assign,nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

@property (readwrite,assign,nonatomic) id <RSTransferFileWindowControllerDelegate> delegate;
@property (readonly,nonatomic) RSCalculator *calculator;
@property (readonly,copy,nonatomic) NSString *statusString;

- (id)initWithCalculator:(RSCalculator *)calculator;

- (void)showTransferFileWindowForTransferFileURLs:(NSArray *)transferFileURLs;

+ (NSArray *)filterTransferFileURLs:(NSArray *)transferFileURLs;

@end
