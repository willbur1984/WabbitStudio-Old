//
//  WCGroup.h
//  WabbitStudio
//
//  Created by William Towe on 1/13/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "WCFile.h"

@interface WCGroup : WCFile <RSPlistArchiving> {
	NSString *_name;
}
@property (readwrite,copy,nonatomic) NSString *name;

+ (id)groupWithFileURL:(NSURL *)fileURL name:(NSString *)name;
- (id)initWithFileURL:(NSURL *)fileURL name:(NSString *)name;
@end
