//
//  WCBreakpointNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/18/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCNavigatorModule.h"
#import "RSOutlineViewDelegate.h"

@class WCProjectDocument,WCBreakpointFileContainer;

@interface WCBreakpointNavigatorViewController : JAViewController <WCNavigatorModule,RSOutlineViewDelegate> {
	__weak WCProjectDocument *_projectDocument;
	WCBreakpointFileContainer *_breakpointFileContainer;
	WCBreakpointFileContainer *_filteredBreakpointFileContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCBreakpointFileContainer *breakpointFileContainer;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

@end
