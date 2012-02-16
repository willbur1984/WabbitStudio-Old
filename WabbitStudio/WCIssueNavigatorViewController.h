//
//  WCIssueNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCNavigatorModule.h"

@class WCProjectDocument,WCIssueContainer;

@interface WCIssueNavigatorViewController : JAViewController <WCNavigatorModule> {
	__weak WCProjectDocument *_projectDocument;
	WCIssueContainer *_issueContainer;
	WCIssueContainer *_filteredIssueContainer;
}
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCIssueContainer *issueContainer;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;
@end
