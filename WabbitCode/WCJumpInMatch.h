//
//  WCJumpInMatch.h
//  WabbitStudio
//
//  Created by William Towe on 1/5/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/NSObject.h>
#import "WCJumpInItem.h"

@interface WCJumpInMatch : NSObject {
	id <WCJumpInItem> _item;
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
