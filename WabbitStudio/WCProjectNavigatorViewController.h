//
//  WCProjectNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"

@class WCProjectContainer;

@interface WCProjectNavigatorViewController : JAViewController {
	WCProjectContainer *_projectContainer;
	WCProjectContainer *_filteredProjectContainer;
	NSString *_filterString;
}
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;

@property (readonly,nonatomic) WCProjectContainer *projectContainer;
@property (readwrite,copy,nonatomic) NSString *filterString;

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer;

- (IBAction)filter:(id)sender;
@end
