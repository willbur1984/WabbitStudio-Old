//
//  WCSearchOperation.h
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSOperation.h>
#import "RSFindOptionsViewController.h"

@class WCSearchNavigatorViewController;

@interface WCSearchOperation : NSOperation {
	WCSearchNavigatorViewController *_searchNavigatorViewController;
	NSArray *_searchDocuments;
	NSString *_searchString;
	RSFindOptionsFindStyle _findStyle;
	RSFindOptionsMatchStyle _matchStyle;
	BOOL _matchCase;
}
- (id)initWithSearchNavigatorViewController:(WCSearchNavigatorViewController *)searchNavigatorViewController;
@end
