//
//  WCTabViewControllerDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/22/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCTabViewController,WCProjectDocument;

@protocol WCTabViewControllerDelegate <NSObject>
@required
- (WCProjectDocument *)projectDocumentForTabViewController:(WCTabViewController *)tabViewController;
@optional
- (NSDictionary *)projectDocumentSettingsForTabViewController:(WCTabViewController *)tabViewController;
@end
