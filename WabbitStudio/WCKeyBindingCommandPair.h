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

extern NSString *const WCKeyBindingCommandPairKeyCodeKey;
extern NSString *const WCKeyBindingCommandPairModifierFlagsKey;
extern NSString *const WCKeyBindingCommandPairTagsKey;
extern NSString *const WCKeyBindingCommandPairCommandModifierMaskKey;
extern NSString *const WCKeyBindingCommandPairOptionModifierMaskKey;
extern NSString *const WCKeyBindingCommandPairControlModifierMaskKey;
extern NSString *const WCKeyBindingCommandPairShiftModifierMaskKey;

@class WCKeyBindingCommandSet;

@interface WCKeyBindingCommandPair : RSTreeNode <RSPlistArchiving,NSCopying,NSMutableCopying> {
	KeyCombo _keyCombo;
	SEL _action;
}
@property (readonly,nonatomic) NSMenuItem *menuItem;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *key;
@property (readwrite,assign,nonatomic) KeyCombo keyCombo;
@property (readonly,nonatomic) WCKeyBindingCommandSet *commandSet;

+ (WCKeyBindingCommandPair *)keyBindingCommandPairForAction:(SEL)action keyCombo:(KeyCombo)keyCombo;
- (id)initWithAction:(SEL)action keyCombo:(KeyCombo)keyCombo;

- (void)updateMenuItemWithCurrentKeyCode;
@end
