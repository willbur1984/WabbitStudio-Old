//
//  WCFontsAndColorsPairsTableView.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software. All rights reserved.
//

#import <AppKit/NSTableView.h>

@interface WCFontsAndColorsPairsTableView : NSTableView {
	NSColor *_selectionColor;
}
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *themesArrayController;
@end
