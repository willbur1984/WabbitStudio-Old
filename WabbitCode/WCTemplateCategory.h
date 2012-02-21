//
//  WCTemplateCategory.h
//  WabbitStudio
//
//  Created by William Towe on 2/19/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"

@interface WCTemplateCategory : RSTreeNode {
	NSURL *_URL;
	NSString *_name;
	NSImage *_icon;
	BOOL _header;
}
@property (readonly,nonatomic) NSURL *URL;
@property (readwrite,copy,nonatomic) NSString *name;
@property (readwrite,retain,nonatomic) NSImage *icon;
@property (readonly,nonatomic,getter = isHeader) BOOL header;

+ (id)templateCategoryWithURL:(NSURL *)url header:(BOOL)header;
- (id)initWithURL:(NSURL *)url header:(BOOL)header;
+ (id)templateCategoryWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;
@end
