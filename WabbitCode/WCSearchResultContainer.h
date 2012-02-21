//
//  WCSearchResultContainer.h
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@class WCSearchResult;

@interface WCSearchResultContainer : RSTreeNode
+ (id)searchResultContainerWithSearchResult:(WCSearchResult *)searchResult;
- (id)initWithSearchResult:(WCSearchResult *)searchResult;
@end
