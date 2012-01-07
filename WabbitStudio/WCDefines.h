//
//  WCDefines.h
//  WabbitStudio
//
//  Created by William Towe on 1/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#ifndef WCDEFINES_H
#define WCDEFINES_H
#ifdef __OBJC__
#import <Foundation/NSDictionary.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSAttributedString.h>

static inline NSDictionary *WCFindTextAttributes() {
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSColor yellowColor],NSBackgroundColorAttributeName,[NSColor orangeColor],NSUnderlineColorAttributeName,[NSNumber numberWithUnsignedInteger:NSUnderlinePatternSolid|NSUnderlineStyleDouble],NSUnderlineStyleAttributeName, nil];
}
static inline NSDictionary *WCTransparentFindTextAttributes() {
	return [NSDictionary dictionaryWithObjectsAndKeys:[[NSColor yellowColor] colorWithAlphaComponent:0.5],NSBackgroundColorAttributeName,[[NSColor orangeColor] colorWithAlphaComponent:0.5],NSUnderlineColorAttributeName,[NSNumber numberWithUnsignedInteger:NSUnderlinePatternSolid|NSUnderlineStyleDouble],NSUnderlineStyleAttributeName, nil];
}
#endif
#endif
