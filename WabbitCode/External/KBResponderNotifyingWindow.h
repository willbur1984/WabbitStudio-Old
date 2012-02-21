//
//  KBResponderNotifyingWindow.h
//  ----------------------------
//
//	Keith Blount 2005
//
//	A simple NSWindow subclass that posts a notification whenever the first responder changes
//

#import <Cocoa/Cocoa.h>

extern NSString *KBWindowFirstResponderDidChangeNotification;

@interface KBResponderNotifyingWindow : NSWindow
@end
