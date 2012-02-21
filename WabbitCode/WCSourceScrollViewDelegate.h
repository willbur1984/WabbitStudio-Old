//
//  WCSourceScrollViewDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 2/17/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceScrollView,WCProjectDocument,WCSourceTextStorage;

@protocol WCSourceScrollViewDelegate <NSObject>
@required
- (NSArray *)buildIssuesForSourceScrollView:(WCSourceScrollView *)scrollView;
- (WCProjectDocument *)projectDocumentForSourceScrollView:(WCSourceScrollView *)scrollView;
- (WCSourceTextStorage *)sourceTextStorageForSourceScrollView:(WCSourceScrollView *)scrollView;
@end
