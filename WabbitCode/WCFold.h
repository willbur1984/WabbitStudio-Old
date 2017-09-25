//
//  WCFold.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSTreeNode.h"
#import "RSToolTipProvider.h"

typedef enum _WCFoldType {
	WCFoldTypeComment,
	WCFoldTypeIf,
	WCFoldTypeMacro
	
} WCFoldType;

@class WCSourceScanner;

@interface WCFold : RSTreeNode <RSToolTipProvider> {
	__unsafe_unretained WCSourceScanner *_sourceScanner;
	WCFoldType _type;
	NSRange _range;
	NSRange _contentRange;
	NSUInteger _level;
	NSAttributedString *_attributedString;
	NSArray *_childFoldsSortedByLevelAndLocation;
}
@property (readwrite,assign,nonatomic) WCSourceScanner *sourceScanner;
@property (readonly,nonatomic) WCFoldType type;
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSRange contentRange;
@property (readwrite,assign,nonatomic) NSUInteger level;
@property (readonly,nonatomic) NSArray *childFoldsSortedByLevelAndLocation;

+ (id)foldOfType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange;
- (id)initWithType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange;
@end
