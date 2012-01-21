//
//  WCDocumentController.h
//  WabbitStudio
//
//  Created by William Towe on 1/8/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSDocumentController.h>

extern NSString *const WCAssemblyFileUTI;
extern NSString *const WCIncludeFileUTI;
extern NSString *const WCActiveServerIncludeFileUTI;
extern NSString *const WCProjectFileUTI;

@interface WCDocumentController : NSDocumentController
@property (readonly,nonatomic) NSArray *recentProjectURLs;
@property (readonly,nonatomic) NSSet *sourceFileDocumentUTIs;
@end
