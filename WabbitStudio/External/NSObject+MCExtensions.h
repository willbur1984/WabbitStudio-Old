#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#define invokeSupersequent(...) \
	([self getImplementationOf:_cmd \
		after:impOfCallingMethod(self, _cmd)]) \
		(self, _cmd, ##__VA_ARGS__)

@interface NSObject (MCExtensions)

IMP impOfCallingMethod(id lookupObject, SEL selector);
-(IMP)getImplementationOf:(SEL)lookup after:(IMP)skip;

@end