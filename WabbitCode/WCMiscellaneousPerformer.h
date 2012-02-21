//
//  WCMiscellaneousPerformer.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@interface WCMiscellaneousPerformer : NSObject

@property (readonly,nonatomic) NSURL *applicationSupportDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationFontAndColorThemesDirectoryURL;
@property (readonly,nonatomic) NSURL *userFontAndColorThemesDirectoryURL;

@property (readonly,nonatomic) NSURL *userKeyBindingCommandSetsDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationProjectTemplatesDirectoryURL;

+ (WCMiscellaneousPerformer *)sharedPerformer;

@end
