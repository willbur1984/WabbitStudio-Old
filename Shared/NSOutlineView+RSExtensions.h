//
//  NSOutlineView+RSExtensions.h
//  WabbitStudio
//
//  Created by William Towe on 7/21/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSOutlineView.h>

@interface NSOutlineView (NSOutlineView_RSExtensions)
- (NSIndexSet *)rowsForItems:(NSArray *)items;

- (id)selectedItem;
- (NSArray *)selectedItems;

- (NSArray *)expandedItems;
- (void)expandItems:(NSArray *)items;

- (NSArray *)expandedModelObjects;
- (void)expandModelObjects:(NSArray *)modelObjects;

- (NSArray *)rootItems;
@end
