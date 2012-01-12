//
//  WCKeyBindingsEditCommandPairWindowController.h
//  WabbitStudio
//
//  Created by William Towe on 1/11/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSWindowController.h>

@class WCKeyBindingCommandPair,SRRecorderControl,SRKeyCodeTransformer;

@interface WCKeyBindingsEditCommandPairWindowController : NSWindowController {
	WCKeyBindingCommandPair *_commandPair;
	SRKeyCodeTransformer *_transformer;
}
@property (readwrite,assign,nonatomic) IBOutlet SRRecorderControl *recorderControl;

+ (WCKeyBindingsEditCommandPairWindowController *)sharedWindowController;

- (void)showEditCommandPairSheetForCommandPair:(WCKeyBindingCommandPair *)commandPair;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
@end
