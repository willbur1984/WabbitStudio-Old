//
//  WCKeyBindingCommandPair.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSTreeNode.h"
#import "SRCommon.h"

static inline KeyCombo WCKeyBindingCommandPairEmptyKeyCombo() {
	KeyCombo combo;
	combo.code = ShortcutRecorderEmptyCode;
	combo.flags = ShortcutRecorderEmptyFlags;
	return combo;
}

@interface WCKeyBindingCommandPair : RSTreeNode {
	KeyCombo _keyCombo;
	SEL _action;
	NSMenuItem *_menuItem;
}
@property (readonly,nonatomic) NSMenuItem *menuItem;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *key;
@property (readwrite,assign,nonatomic) KeyCombo keyCombo;

+ (WCKeyBindingCommandPair *)keyBindingCommandPairForAction:(SEL)action keyCombo:(KeyCombo)keyCombo;
- (id)initWithAction:(SEL)action keyCombo:(KeyCombo)keyCombo;

@end
