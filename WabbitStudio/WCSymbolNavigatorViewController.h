//
//  WCSymbolNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "WCNavigatorModule.h"

@class WCProjectDocument,WCSymbolFileContainer;

@interface WCSymbolNavigatorViewController : JAViewController <WCNavigatorModule> {
	__weak WCProjectDocument *_projectDocument;
	WCSymbolFileContainer *_symbolFileContainer;
	WCSymbolFileContainer *_filteredSymbolFileContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCSymbolFileContainer *symbolFileContainer;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

@end
