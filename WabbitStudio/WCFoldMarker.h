//
//  WCFoldMarker.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

typedef enum _WCFoldMarkerType {
	WCFoldMarkerTypeMacroStart = 1,
	WCFoldMarkerTypeMacroEnd,
	WCFoldMarkerTypeIfStart,
	WCFoldMarkerTypeIfEnd,
	WCFoldMarkerTypeCommentStart,
	WCFoldMarkerTypeCommentEnd
	
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
