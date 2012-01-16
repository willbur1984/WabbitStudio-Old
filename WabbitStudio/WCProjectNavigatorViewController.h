//
//  WCProjectNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 1/14/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "JAViewController.h"
#import "RSOutlineView.h"
#import "RSFindOptionsViewControllerDelegate.h"
#import "WCNavigatorModule.h"
#import <Quartz/Quartz.h>

@class WCProjectContainer,RSFindOptionsViewController;

@interface WCProjectNavigatorViewController : JAViewController <WCNavigatorModule,RSOutlineViewDelegate,RSFindOptionsViewControllerDelegate,QLPreviewPanelDataSource,QLPreviewPanelDelegate> {
	WCProjectContainer *_projectContainer;
	WCProjectContainer *_filteredProjectContainer;
	NSString *_filterString;
	RSFindOptionsViewController *_filterOptionsViewController;
	struct {
		unsigned int switchTreeControllerContentBinding:1;
		unsigned int RESERVED:31;
	} _projectNavigatorFlags;
}
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;

@property (readonly,nonatomic) WCProjectContainer *projectContainer;
@property (readwrite,copy,nonatomic) NSString *filterString;

- (id)initWithProjectContainer:(WCProjectContainer *)projectContainer;

- (IBAction)filter:(id)sender;
- (IBAction)toggleFilterOptions:(id)sender;
- (IBAction)showFilterOptions:(id)sender;
- (IBAction)hideFilterOptions:(id)sender;
@end
