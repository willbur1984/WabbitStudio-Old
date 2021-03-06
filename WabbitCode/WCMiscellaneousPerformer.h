//
//  WCMiscellaneousPerformer.h
//  WabbitEdit
//
//  Created by William Towe on 12/28/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/NSObject.h>

@interface WCMiscellaneousPerformer : NSObject

@property (readonly,nonatomic) NSURL *applicationSupportDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationFontAndColorThemesDirectoryURL;
@property (readonly,nonatomic) NSURL *userFontAndColorThemesDirectoryURL;

@property (readonly,nonatomic) NSURL *userKeyBindingCommandSetsDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationProjectTemplatesDirectoryURL;
@property (readonly,nonatomic) NSURL *userProjectTemplatesDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationFileTemplatesDirectoryURL;
@property (readonly,nonatomic) NSURL *userFileTemplatesDirectoryURL;

@property (readonly,nonatomic) NSURL *applicationIncludeFilesDirectoryURL;

+ (WCMiscellaneousPerformer *)sharedPerformer;

@end
