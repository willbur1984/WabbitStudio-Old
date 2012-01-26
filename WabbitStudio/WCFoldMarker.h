//
//  WCFoldMarker.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

typedef enum _WCFoldMarkerType {
	WCFoldMarkerTypeMacroStart = 0,
	WCFoldMarkerTypeMacroEnd = 1,
	WCFoldMarkerTypeIfStart = 2,
	WCFoldMarkerTypeIfEnd = 3,
	WCFoldMarkerTypeCommentStart = 4,
	WCFoldMarkerTypeCommentEnd = 5
	
} WCFoldMarkerType;

@interface WCFoldMarker : NSObject {
	WCFoldMarkerType _type;
	NSRange _range;
}
@property (readonly,nonatomic) WCFoldMarkerType type;
@property (readonly,nonatomic) NSRange range;

+ (id)foldMarkerOfType:(WCFoldMarkerType)type range:(NSRange)range;
- (id)initWithType:(WCFoldMarkerType)type range:(NSRange)range;
@end
