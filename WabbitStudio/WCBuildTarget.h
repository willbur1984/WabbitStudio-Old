//
//  WCBuildTarget.h
//  WabbitStudio
//
//  Created by William Towe on 2/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

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
	__weak WCProjectDocument *_projectDocument;
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

+ (WCBuildTarget *)buildTargetWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType projectDocument:(WCProjectDocument *)projectDocument;
- (id)initWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType projectDocument:(WCProjectDocument *)projectDocument;
@end
