//
//  WCSourceGlyphGenerator.h
//  WabbitStudio
//
//  Created by William Towe on 1/27/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <AppKit/NSGlyphGenerator.h>

@interface WCSourceGlyphGenerator : NSGlyphGenerator <NSGlyphStorage> {
	id <NSGlyphStorage> _destination;
}
@end
