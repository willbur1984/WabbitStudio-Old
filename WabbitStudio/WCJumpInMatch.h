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
	CGFloat _weight;
}
@property (readonly,nonatomic) id <WCJumpInItem> item;
@property (readonly,nonatomic) NSAttributedString *name;
@property (readonly,nonatomic) CGFloat weight;

+ (WCJumpInMatch *)jumpInMatchWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight;
- (id)initWithItem:(id<WCJumpInItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight;
@end
