//
//  WCTemplate.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

extern NSString *const WCTemplateInfoPlistName;
extern NSString *const WCTemplateInfoPlistExtension;

extern NSString *const WCTemplateInfoSummaryKey;
extern NSString *const WCTemplateInfoMainFileNameKey;
extern NSString *const WCTemplateInfoMainFileEncodingKey;

@interface WCTemplate : RSTreeNode {
	NSURL *_URL;
	NSDictionary *_info;
	NSImage *_icon;
	NSString *_name;
}
@property (readonly,nonatomic) NSURL *URL;
@property (readonly,nonatomic) NSDictionary *info;
@property (readwrite,retain,nonatomic) NSImage *icon;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *summary;
@property (readonly,nonatomic) NSString *mainFileName;
@property (readonly,nonatomic) NSStringEncoding mainFileEncoding;

+ (id)templateWithURL:(NSURL *)url error:(NSError **)outError;
- (id)initWithURL:(NSURL *)url error:(NSError **)outError;

@end
