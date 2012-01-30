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

@interface WCFold : RSTreeNode <RSToolTipProvider> {
	WCFoldType _type;
	NSRange _range;
	NSRange _contentRange;
	NSUInteger _level;
	NSString *_string;
}
@property (readonly,nonatomic) WCFoldType type;
@property (readonly,nonatomic) NSRange range;
@property (readonly,nonatomic) NSRange contentRange;
@property (readwrite,assign,nonatomic) NSUInteger level;
@property (readonly,nonatomic) NSString *string;

+ (id)foldOfType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange string:(NSString *)string;
- (id)initWithType:(WCFoldType)type level:(NSUInteger)level range:(NSRange)range contentRange:(NSRange)contentRange string:(NSString *)string;
@end
