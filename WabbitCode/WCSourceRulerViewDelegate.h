//
//  WCSourceRulerViewDelegate.h
//  WabbitStudio
//
//  Created by William Towe on 1/24/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceRulerView,WCSourceScanner,WCProjectDocument,WCFile;

@protocol WCSourceRulerViewDelegate <NSObject>
@required
- (WCSourceScanner *)sourceScannerForSourceRulerView:(WCSourceRulerView *)rulerView;
- (NSArray *)buildIssuesForSourceRulerView:(WCSourceRulerView *)rulerView;
- (WCProjectDocument *)projectDocumentForSourceRulerView:(WCSourceRulerView *)rulerView;
- (NSArray *)fileBreakpointsForSourceRulerView:(WCSourceRulerView *)rulerView;
- (WCFile *)fileForSourceRulerView:(WCSourceRulerView *)rulerView;
@end