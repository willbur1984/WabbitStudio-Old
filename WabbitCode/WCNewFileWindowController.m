//
//  WCNewFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 3/2/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCNewFileWindowController.h"
#import "WCProjectDocument.h"
#import "WCFileTemplate.h"

@interface WCNewFileWindowController ()

@end

@implementation WCNewFileWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_projectDocument = nil;
	[_categories release];
	[super dealloc];
}

- (NSString *)windowNibName {
	return @"WCNewFileWindow";
}
#pragma mark *** Public Methods ***
+ (WCNewFileWindowController *)sharedWindowController; {
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[[self class] alloc] initWithProjectDocument:nil];
	});
	return sharedInstance;
}

+ (id)newFileWindowControllerWithProjectDocument:(WCProjectDocument *)projectDocument; {
	return [[[[self class] alloc] initWithProjectDocument:projectDocument] autorelease];
}
- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
	if (!(self = [super initWithWindowNibName:[self windowNibName]]))
		return nil;
	
	_projectDocument = projectDocument;
	
	return self;
}

- (void)showNewFileWindow; {
	if ([self projectDocument]) {
		// so clang will shut up
		[self performSelector:@selector(retain)];
		
		[[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:[[self projectDocument] windowForSheet] modalDelegate:self didEndSelector:@selector(_sheetDidEnd:code:context:) contextInfo:NULL];
	}
	else {
		NSInteger result = [[NSApplication sharedApplication] runModalForWindow:[self window]];
		
		if (result == NSOKButton) {
			// TODO: create our new file
		}
	}
}
#pragma mark IBActions
- (IBAction)cancel:(id)sender; {
	if ([self projectDocument])
		[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
	else {
		[[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
		[[self window] orderOut:nil];
	}
}
- (IBAction)create:(id)sender; {
	if ([self projectDocument])
		[[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
	else {
		[[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
		[[self window] orderOut:nil];
	}
}

#pragma mark Properties
@synthesize categoriesArrayController=_categoriesArrayController;
@synthesize collectionView=_collectionView;
@synthesize splitterHandleImageView=_splitterHandleImageView;

@synthesize categories=_categories;
@dynamic mutableCategories;
- (NSMutableArray *)mutableCategories {
	return [self mutableArrayValueForKey:@"categories"];
}
- (NSUInteger)countOfCategories {
	return [_categories count];
}
- (NSArray *)categoriesAtIndexes:(NSIndexSet *)indexes {
	return [_categories objectsAtIndexes:indexes];
}
- (void)insertCategories:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
	[_categories insertObjects:array atIndexes:indexes];
}
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes {
	[_categories removeObjectsAtIndexes:indexes];
}
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray *)array {
	[_categories replaceObjectsAtIndexes:indexes withObjects:array];
}
@synthesize projectDocument=_projectDocument;

#pragma mark *** Private Methods ***

#pragma mark Callbacks
- (void)_sheetDidEnd:(NSWindow *)sheet code:(NSInteger)code context:(void *)context; {
	// to balance the retain in the showNewFileWindow method
	[self autorelease];
	[sheet orderOut:nil];
	if (code == NSCancelButton)
		return;
	
	// TODO: create our new file
}

@end
