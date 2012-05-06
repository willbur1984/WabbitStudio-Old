//
//  WCProject.m
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProject.h"
#import "WCProjectDocument.h"
#import "NSURL+RSExtensions.h"
#import "NSString+RSExtensions.h"
#import "WCBuildTarget.h"

static NSString *const WCProjectBuildTargetsKey = @"buildTargets";

@interface WCProject ()
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@end

@implementation WCProject
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
	_document = nil;
	[super dealloc];
}

- (NSString *)fileName {
	return [[self document] displayName];
}
- (NSImage *)fileIcon {
	return [NSImage imageNamed:@"project"];
}
- (NSURL *)fileURL {
	return [[self document] fileURL];
}
- (NSString *)filePath {
	return [[self fileURL] path];
}
- (BOOL)isSourceFile {
	return NO;
}
- (BOOL)isEdited {
	return NO;
}
- (NSString *)fileUTI {
	return [[self fileURL] fileUTI];
}

- (NSDictionary *)plistRepresentation {
	NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[retval setObject:[self className] forKey:RSObjectClassNameKey];
	[retval setObject:[self UUID] forKey:WCFileUUIDKey];
	
	return [[retval copy] autorelease];
}

#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == self) {
		if ([keyPath isEqualToString:@"buildTargets"]) {
			NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
			
			if (changeKind == NSKeyValueChangeInsertion) {
				[self willChangeValueForKey:@"fileStatus"];
				
				NSArray *buildTargets = [change objectForKey:NSKeyValueChangeNewKey];
				
				for (WCBuildTarget *buildTarget in buildTargets)
					[self _startObservingBuildTarget:buildTarget];
				
				[self didChangeValueForKey:@"fileStatus"];
			}
			else if (changeKind == NSKeyValueChangeRemoval) {
				[self willChangeValueForKey:@"fileStatus"];
				
				NSArray *buildTargets = [change objectForKey:NSKeyValueChangeOldKey];
				
				for (WCBuildTarget *buildTarget in buildTargets)
					[self _stopObservingBuildTarget:buildTarget];
				
				[self didChangeValueForKey:@"fileStatus"];
			}
		}
		else if ([keyPath isEqualToString:@"name"]) {
			[self willChangeValueForKey:@"fileStatus"];
			[self didChangeValueForKey:@"fileStatus"];
		}
		else if ([keyPath isEqualToString:@"active"]) {
			[self willChangeValueForKey:@"fileStatus"];
			[self didChangeValueForKey:@"fileStatus"];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark *** Public Methods ***
+ (id)projectWithDocument:(WCProjectDocument *)document; {
	return [[(WCProject *)[[self class] alloc] initWithDocument:document] autorelease];
}
- (id)initWithDocument:(WCProjectDocument *)document; {
	if (!(self = [super init]))
		return nil;
	
	_UUID = [[NSString UUIDString] copy];
	_document = document;
	
	return self;
}

- (void)performSetup; {	
	[[self projectDocument] addObserver:self forKeyPath:@"buildTargets" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:self];
	
	for (WCBuildTarget *buildTarget in [[self projectDocument] buildTargets])
		[self _startObservingBuildTarget:buildTarget];
}
- (void)performCleanup; {
	[[self projectDocument] removeObserver:self forKeyPath:@"buildTargets" context:self];
	
	for (WCBuildTarget *buildTarget in [[self projectDocument] buildTargets])
		[self _stopObservingBuildTarget:buildTarget];
}

#pragma mark Properties
@synthesize document=_document;
@dynamic fileStatus;
- (NSString *)fileStatus {
	NSArray *buildTargets = [[self document] buildTargets];
	WCBuildTarget *activeBuildTarget = [[self document] activeBuildTarget];
	
	if ([buildTargets count] == 1) {
		if (activeBuildTarget)
			return [NSString stringWithFormat:NSLocalizedString(@"1 target, \"%@\" is active", @"1 target and active target format string"),[activeBuildTarget name]];
		return NSLocalizedString(@"1 target, no active target", @"1 target, no active target");
	}
	else if (activeBuildTarget)
		return [NSString stringWithFormat:NSLocalizedString(@"%lu targets, \"%@\" is active", @"multiple targets and active target format string"),[buildTargets count],[activeBuildTarget name]];
	return [NSString stringWithFormat:NSLocalizedString(@"%lu targets, no active target", @"multiple targets and no active target format string"),[buildTargets count]];
}
@dynamic projectDocument;
- (WCProjectDocument *)projectDocument {
	return [self document];
}
#pragma mark *** Private Methods ***
- (void)_startObservingBuildTarget:(WCBuildTarget *)buildTarget; {
	[buildTarget addObserver:self forKeyPath:@"name" options:0 context:self];
	[buildTarget addObserver:self forKeyPath:@"active" options:0 context:self];
}
- (void)_stopObservingBuildTarget:(WCBuildTarget *)buildTarget; {
	[buildTarget removeObserver:self forKeyPath:@"name" context:self];
	[buildTarget removeObserver:self forKeyPath:@"active" context:self];
}

@end
