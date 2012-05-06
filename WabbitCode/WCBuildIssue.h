//
//  WCBuildIssue.h
//  WabbitStudio
//
//  Created by William Towe on 2/15/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
