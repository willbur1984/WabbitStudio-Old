//
//  WCJumpInMatch.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "WCJumpInItem.h"

@interface WCJumpInMatch : NSObject {
	__weak id <WCJumpInItem> _item;
	NSAttributedString *_name;
	NSArray *_ranges;
	NSArray *_weights;
}
@property (readonly,nonatomic) id <WCJumpInItem> item;
@property (readonly,nonatomic) NSAttributedString *name;
@property (readonly,nonatomic) CGFloat contiguousRangeWeight;
@property (readonly,nonatomic) CGFloat lengthDifferenceWeight;
@property (readonly,nonatomic) CGFloat matchOffsetWeight;

+ (WCJumpInMatch *)jumpInMatchWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights;
- (id)initWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weights:(NSArray *)weights;
@end
