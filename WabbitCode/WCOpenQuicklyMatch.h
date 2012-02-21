//
//  WCOpenQuicklyMatch.h
//  WabbitStudio
//
//  Created by William Towe on 1/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCOpenQuicklyItem.h"

@interface WCOpenQuicklyMatch : NSObject {
	id <WCOpenQuicklyItem> _item;
	NSAttributedString *_name;
	NSArray *_ranges;
	NSArray *_weights;
}
@property (readonly,nonatomic) id <WCOpenQuicklyItem> item;
@property (readonly,nonatomic) NSAttributedString *name;
@property (readonly,nonatomic) CGFloat contiguousRangeWeight;
@property (readonly,nonatomic) CGFloat lengthDifferenceWeight;
@property (readonly,nonatomic) CGFloat matchOffsetWeight;

+ (WCOpenQuicklyMatch *)openQuicklyMatchWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights;
- (id)initWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights;
@end
