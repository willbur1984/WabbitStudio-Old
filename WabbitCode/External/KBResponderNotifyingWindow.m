//
//  KBResponderNotifyingWindow.m
//  ----------------------------
//
//  Keith Blount 2005
//

#import "KBResponderNotifyingWindow.h"

NSString *KBWindowFirstResponderDidChangeNotification = @"KBWindowFirstResponderDidChangeNotification";

@implementation KBResponderNotifyingWindow

- (BOOL)makeFirstResponder:(NSResponder *)aResponder
{
	NSResponder *oldResponder = [self firstResponder];
	BOOL responderChanged = [super makeFirstResponder:aResponder];
	
	if ( (responderChanged) && (oldResponder!=aResponder) )
	{
		NSDictionary *userInfo;
		
		if (aResponder)
		{
			userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				aResponder,@"NewFirstResponder",
				oldResponder,@"OldFirstResponder",
				nil];
		}
		else
			userInfo = [NSDictionary dictionaryWithObject:oldResponder forKey:@"OldFirstResponder"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:KBWindowFirstResponderDidChangeNotification
															object:self
														  userInfo:userInfo];
	}
	return responderChanged;
}

@end
