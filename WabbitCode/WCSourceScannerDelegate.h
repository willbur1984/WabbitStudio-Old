//
//  WCSourceScannerDelegate.h
//  WabbitEdit
//
//  Created by William Towe on 12/29/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@class WCSourceScanner,WCSourceFileDocument,WCSourceHighlighter;

@protocol WCSourceScannerDelegate <NSObject>
@required
- (WCSourceHighlighter *)sourceHighlighterForSourceScanner:(WCSourceScanner *)scanner;
- (NSString *)fileDisplayNameForSourceScanner:(WCSourceScanner *)scanner;
- (WCSourceFileDocument *)sourceFileDocumentForSourceScanner:(WCSourceScanner *)scanner;
- (NSURL *)fileURLForSourceScanner:(WCSourceScanner *)scanner;
- (NSURL *)locationURLForSourceScanner:(WCSourceScanner *)scanner;
- (NSArray *)sourceScanner:(WCSourceScanner *)scanner completionsForPrefix:(NSString *)prefix;
@end
