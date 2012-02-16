//
//  WCBuildIssue.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

typedef enum _WCBuildIssueType {
	WCBuildIssueTypeError = 0,
	WCBuildIssueTypeWarning
	
} WCBuildIssueType;

@interface WCBuildIssue : NSObject {
	WCBuildIssueType _type;
	NSRange _range;
	NSString *_message;
	NSString *_code;
}
@property (readonly,nonatomic) WCBuildIssueType type;
@property (readwrite,assign,nonatomic) NSRange range;
@property (readonly,nonatomic) NSString *message;
@property (readonly,nonatomic) NSString *code;

+ (id)buildIssueOfType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code;
- (id)initWithType:(WCBuildIssueType)type range:(NSRange)range message:(NSString *)message code:(NSString *)code;

@end
