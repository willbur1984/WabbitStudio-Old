//
//  WCBuildTarget.h
//  WabbitStudio
//
//  Created by William Towe on 2/10/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSObject.h"

enum {
	WCBuildTargetOutputTypeBinary = 0,
	WCBuildTargetOutputType73Program = 1,
	WCBuildTargetOutputType82Program = 2,
	WCBuildTargetOutputType83Program = 3,
	WCBuildTargetOutputType83PlusProgram = 4,
	WCBuildTargetOutputType83PlusApplication = 5,
	WCBuildTargetOutputType85Program = 6,
	WCBuildTargetOutputType86Program = 7
};
typedef NSUInteger WCBuildTargetOutputType;

@class WCProject;

@interface WCBuildTarget : RSObject <RSPlistArchiving,NSCopying,NSMutableCopying> {
	__weak WCProject *_project;
	WCBuildTargetOutputType _outputType;
	NSString *_name;
	NSMutableArray *_defines;
	NSMutableArray *_includes;
	NSMutableArray *_steps;
	struct {
		unsigned int active:1;
		unsigned int generateCodeListing:1;
		unsigned int generateLabelFile:1;
		unsigned int symbolsAreCaseSensitive:1;
		unsigned int RESERVED:28;
	} _buildTargetFlags;
}
@property (readwrite,assign,nonatomic) WCBuildTargetOutputType outputType;
@property (readwrite,copy,nonatomic) NSString *name;
@property (readonly,nonatomic) NSImage *icon;
@property (readonly,nonatomic) NSArray *defines;
@property (readonly,nonatomic) NSMutableArray *mutableDefines;
@property (readonly,nonatomic) NSArray *includes;
@property (readonly,nonatomic) NSMutableArray *mutableIncludes;
@property (readonly,nonatomic) NSArray *steps;
@property (readonly,nonatomic) NSMutableArray *mutableSteps;
@property (readwrite,assign,nonatomic,getter = isActive) BOOL active;
@property (readwrite,assign,nonatomic) BOOL generateCodeListing;
@property (readwrite,assign,nonatomic) BOOL generateLabelFile;
@property (readwrite,assign,nonatomic) BOOL symbolsAreCaseSensitive;

+ (WCBuildTarget *)buildTargetWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType;
- (id)initWithName:(NSString *)name outputType:(WCBuildTargetOutputType)outputType;
@end
