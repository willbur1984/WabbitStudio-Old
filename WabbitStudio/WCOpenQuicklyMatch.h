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
	__weak id <WCOpenQuicklyItem> _item;
	NSAttributedString *_name;
	NSArray *_ranges;
	CGFloat _weight;
}
@property (readonly,nonatomic) id <WCOpenQuicklyItem> item;
@property (readonly,nonatomic) NSAttributedString *name;
@property (readonly,nonatomic) CGFloat weight;

+ (WCOpenQuicklyMatch *)openQuicklyMatchWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight;
- (id)initWithItem:(id<WCOpenQuicklyItem>)item ranges:(NSArray *)ranges weight:(CGFloat)weight;
@end
