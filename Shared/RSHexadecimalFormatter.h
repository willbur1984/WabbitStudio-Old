//
//  RSHexadecimalFormatter.h
//  WabbitStudio
//
//  Created by William Towe on 8/18/11.
//  Copyright 2011 Revolution Software. All rights reserved.
//

#import <Foundation/NSFormatter.h>

enum {
	RSHexadecimalFormatDefault,
	RSHexadecimalFormatUnsignedChar,
	RSHexadecimalFormatUnsignedShort,
	RSHexadecimalFormatUnsignedInt,
	RSHexadecimalFormatUppercaseDefault,
	RSHexadecimalFormatUppercaseUnsignedChar,
	RSHexadecimalFormatUppercaseUnsignedShort,
	RSHexadecimalFormatUppercaseUnsignedInt
};
typedef NSUInteger RSHexadecimalFormat;

enum {
	RSInputFormatDefault,
	RSInputFormatBaseTen,
	RSInputFormatBaseTwo,
	RSInputFormatBaseSixteen = RSInputFormatDefault
};
typedef NSUInteger RSInputFormat;

@interface RSHexadecimalFormatter : NSFormatter
@property (readwrite,assign,nonatomic) RSHexadecimalFormat hexadecimalFormat;
@property (readwrite,assign,nonatomic) RSInputFormat inputFormat; 
@end
