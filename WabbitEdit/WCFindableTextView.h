//
//  WCFindableTextView.h
//  WabbitEdit
//
//  Created by William Towe on 1/4/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSTextView.h>

@class RSFindBarViewController;

@interface WCFindableTextView : NSTextView {
	RSFindBarViewController *_findBarViewController;
	id _windowWillCloseObservingToken;
}
@property (readonly,nonatomic) RSFindBarViewController *findBarViewController;
@end
