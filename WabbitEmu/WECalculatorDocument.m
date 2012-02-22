//
//  WECalculatorDocument.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WECalculatorDocument.h"
#import "RSCalculator.h"
#import "WECalculatorWindowController.h"

@interface WECalculatorDocument ()
@property (readwrite,retain,nonatomic) RSCalculator *calculator;
@end

@implementation WECalculatorDocument

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	[_calculator release];
	[super dealloc];
}

- (void)makeWindowControllers {
	WECalculatorWindowController *windowController = [[[WECalculatorWindowController alloc] initWithCalculatorDocument:self] autorelease];
	
	[windowController setShouldCloseDocument:YES];
	
	[self addWindowController:windowController];
}

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	[self setHasUndoManager:NO];
	[self setUndoManager:nil];
	
	return self;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
	RSCalculator *calculator = [[[RSCalculator alloc] initWithRomOrSavestateURL:url error:outError] autorelease];
	
	if (!calculator)
		return NO;
	
	[calculator setDelegate:self];
	[self setCalculator:calculator];
	
	return YES;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (void)calculator:(RSCalculator *)calculator didLoadRomOrSavestateURL:(NSURL *)romOrSavestateURL; {
	[self setFileURL:romOrSavestateURL];
	
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:romOrSavestateURL];
}

@synthesize calculator=_calculator;

@end
