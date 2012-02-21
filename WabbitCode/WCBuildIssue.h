//
//  WCBuildIssue.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "RSToolTipProvider.h"

typedef enum _WCBuildIssueType {
	WCBuildIssueTypeError = 0,
	WCBuildIssueTypeWarning,
	WCBuildIssueTypeProject
	
} WCBuildIssueType;

@interface WCBuildIssue : NSObject <RSToolTipProvider> {
	WCBuildIssueType _type;
	NSRange _range;
	NSString *_message;
	NSString *_code;
	struct {
		unsigned int visible:1;
		unsigned int RESERVED:31;
	} _buildIssueFlags;
}
@property (readonly,nonatomic) WCBuildIssueType type;
@property (readwrite,assign,nonatomic) NSRange range;
@property (readonly,nonatomic) NSString *message;
@property (readonly,nonatomic) NSString *code;
@property (readonly,nonatomic) NSImage *icon;
@property (readwrite,assign,nonatomic,getter = isVisible) BOOL visible;

+ (id)buildIssueOfType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code;
- (id)initWithType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code;

+ (NSGradient *)errorFillGradient;
+ (NSGradient *)errorSelectedFillGradient;
+ (NSColor *)errorFillColor;
+ (NSGradient *)warningFillGradient;
+ (NSGradient *)warningSelectedFillGradient;
+ (NSColor *)warningFillColor;
@end
