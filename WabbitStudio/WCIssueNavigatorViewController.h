//
//  WCIssueNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCNavigatorModule.h"
#import "RSOutlineViewDelegate.h"

@class WCProjectDocument,WCIssueContainer;

@interface WCIssueNavigatorViewController : JAViewController <WCNavigatorModule,RSOutlineViewDelegate> {
	__weak WCProjectDocument *_projectDocument;
	WCIssueContainer *_issueContainer;
	WCIssueContainer *_filteredIssueContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCIssueContainer *issueContainer;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;
@end
