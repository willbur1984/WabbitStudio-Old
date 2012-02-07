//
//  WCSearchNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/6/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCNavigatorModule.h"

@class WCProjectContainer,WCSearchContainer;

@interface WCSearchNavigatorViewController : JAViewController <WCNavigatorModule> {
	WCProjectContainer *_projectContainer;
	WCSearchContainer *_searchContainer;
	WCSearchContainer *_filteredSearchContainer;
}

@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *filterField;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCSearchContainer *searchContainer;
@property (readonly,nonatomic) WCSearchContainer *filteredSearchContainer;

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer;

@end
