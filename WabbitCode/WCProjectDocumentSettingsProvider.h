//
//  WCProjectDocumentSettingsProvider.h
//  WabbitStudio
//
//  Created by William Towe on 1/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@protocol WCProjectDocumentSettingsProvider <NSObject>
@required
@property (readonly,nonatomic) NSString *projectDocumentSettingsKey;
@property (readonly,nonatomic) NSDictionary *projectDocumentSettings;
@end
