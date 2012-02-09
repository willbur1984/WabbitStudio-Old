//
//  WCSearchResult.h
//  WabbitStudio
//
//  Created by William Towe on 2/7/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>

@interface WCSearchResult : NSObject {
	NSRange _range;
	id _tokenOrSymbol;
	NSString *_string;
	NSAttributedString *_attributedString;
}
@property (readwrite,assign,nonatomic) NSRange range;
@property (readonly,nonatomic) id tokenOrSymbol;
@property (readonly,nonatomic) NSString *string;
@property (readonly,nonatomic) NSAttributedString *attributedString;

+ (WCSearchResult *)searchResultWithRange:(NSRange)range string:(NSString *)string attributedString:(NSAttributedString *)attributedString tokenOrSymbol:(id)tokenOrSymbol;
- (id)initWithRange:(NSRange)range string:(NSString *)string attributedString:(NSAttributedString *)attributedString tokenOrSymbol:(id)tokenOrSymbol;

@end
