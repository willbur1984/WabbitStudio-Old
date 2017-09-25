//
//  WCBuildTarget.h
//  WabbitStudio
//
//  Created by William Towe on 2/10/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RSObject.h"

typedef enum _WCBuildTargetOutputType {
	WCBuildTargetOutputTypeBinary = 0,
	WCBuildTargetOutputType73Program = 1,
	WCBuildTargetOutputType82Program = 2,
	WCBuildTargetOutputType83Program = 3,
	WCBuildTargetOutputType83PlusProgram = 4,
	WCBuildTargetOutputType83PlusApplication = 5,
	WCBuildTargetOutputType85Program = 6,
	WCBuildTargetOutputType86Program = 7
	
} WCBuildTargetOutputType;

@class WCProjectDocument,WCFile;

@interface WCBuildTarget : RSObject <RSPlistArchiving,NSCopying,NSMutableCopying> {
	__unsafe_unretained WCProjectDocument *_projectDocument;
	WCBuildTargetOutputType _outputType;
	NSString *_name;
	WCFile *_inputFile;
	NSString *_inputFileUUID;
	NSMutableArray *_defines;
	NSMutableArray *_includes;
	struct {
		unsigned int active:1;
		unsigned int generateCodeListing:1;
		unsigned int generateLabelFile:1;
		unsigned int symbolsAreCaseSensitive:1;
		unsigned int RESERVED:28;
	} _buildTargetFlags;
}
@property (readwrite,assign,nonatomic) WCProjectDocument *projectDocument;
@property (readwrite,assign,nonatomic) WCBuildTargetOutputType outputType;
@property (readwrite,copy,nonatomic) NSString *name;
@property (readonly,nonatomic) NSImage *icon;
@property (readwrite,retain,nonatomic) WCFile *inputFile;
@property (readonly,nonatomic) NSArray *defines;
@property (readonly,nonatomic) NSMutableArray *mutableDefines;
@property (readonly,nonatomic) NSArray *includes;
@property (readonly,nonatomic) NSMutableArray *mutableIncludes;
@property (readwrite,assign,nonatomic,getter = isActive) BOOL active;
@property (readwrite,assign,nonatomic) BOOL generateCodeListing;
@property (readwrite,assign,nonatomic) BOOL generateLabelFile;
@property (readwrite,assign,nonatomic) BOOL symbolsAreCaseSensitive;
@property (readonly,nonatomic) NSString *outputFileExtension;

+ (WCBuildTarget *)buildTargetWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType projectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType projectDocument:(WCProjectDocument *)projectDocument;
@end
