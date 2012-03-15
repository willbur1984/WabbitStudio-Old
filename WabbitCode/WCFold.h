//
//  WCFold.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"
#import "RSToolTipProvider.h"

typedef enum _WCFoldType {
	WCFoldTypeComment,
	WCFoldTypeIf,
	WCFoldTypeMacro
	
} WCFoldType;

@class WCSourceScanner;

@interface WCFold : RSTreeNode <RSToolTipProvider> {
	__weak WCSourceScanner *_sourceScanner;
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
