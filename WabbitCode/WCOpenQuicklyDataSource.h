//
//  WCOpenQuicklyDataSource.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCProjectDocument;

@protocol WCOpenQuicklyDataSource <NSObject>
@required
// return an array of id <WCOpenQuicklyItem> objects
- (NSArray *)openQuicklyItems;
- (NSString *)openQuicklyProjectName;
- (WCProjectDocument *)openQuicklyProjectDocument;
@end
