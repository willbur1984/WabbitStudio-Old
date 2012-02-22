//
//  RSCalculator.h
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import <Foundation/NSObject.h>
#import "RSCalculatorDelegate.h"
#include "calc.h"

typedef enum _RSCalculatorModel {
	RSCalculatorModelTI_73 = TI_73,
	RSCalculatorModelTI_81 = TI_81,
	RSCalculatorModelTI_82 = TI_82,
	RSCalculatorModelTI_83 = TI_83,
	RSCalculatorModelTI_83P = TI_83P,
	RSCalculatorModelTI_83PSE = TI_83PSE,
	RSCalculatorModelTI_84P = TI_84P,
	RSCalculatorModelTI_84PSE = TI_84PSE,
	RSCalculatorModelTI_85 = TI_85,
	RSCalculatorModelTI_86 = TI_86
	
} RSCalculatorModel;

typedef enum _RSBreakpointType {
	RSBreakpointTypeNone = 0,
	RSBreakpointTypeNormal,
	RSBreakpointTypeRead,
	RSBreakpointTypeWrite,
	RSBreakpointTypeFile
	
} RSBreakpointType;

extern NSString *const RSCalculatorRomUTI;
extern NSString *const RSCalculatorSavestateUTI;
extern NSString *const RSCalculatorProgramUTI;
extern NSString *const RSCalculatorApplicationUTI;
extern NSString *const RSCalculatorGroupFileUTI;
extern NSString *const RSCalculatorPictureFileUTI;

extern NSString *const RSCalculatorLabelFileUTI;

extern NSString *const RSCalculatorWillLoadRomOrSavestateNotification;
extern NSString *const RSCalculatorDidLoadRomOrSavestateNotification;

extern NSString *const RSCalculatorErrorDomain;
extern const NSInteger RSCalculatorErrorCodeUnrecognizedRomOrSavestate;
extern const NSInteger RSCalculatorErrorCodeMaximumNumberOfCalculators;

@interface RSCalculator : NSObject {
	__weak id <RSCalculatorDelegate> _delegate;
	LPCALC _calculator;
	NSURL *_lastLoadedURL;
	struct {
		unsigned int loading:1;
		unsigned int debugging:1;
		unsigned int RESERVED:30;
	} _calculatorFlags;
}
@property (readwrite,assign,nonatomic) id <RSCalculatorDelegate> delegate;
@property (readonly,nonatomic) LPCALC calculator;
@property (readonly,assign,nonatomic,getter = isLoading) BOOL loading;
@property (readwrite,assign,nonatomic,getter = isDebugging) BOOL debugging;
@property (readwrite,assign,nonatomic,getter = isActive) BOOL active;
@property (readwrite,assign,nonatomic,getter = isRunning) BOOL running;
@property (readonly,nonatomic) RSCalculatorModel model;
@property (readonly,nonatomic) NSString *modelString;
@property (readonly,nonatomic) NSImage *skinImage;
@property (readonly,nonatomic) NSImage *keymapImage;

@property (readwrite,assign,nonatomic) uint16_t programCounter;
@property (readwrite,assign,nonatomic) uint16_t stackPointer;
@property (readwrite,assign,nonatomic) uint16_t registerAF;
@property (readwrite,assign,nonatomic) uint16_t registerAFPrime;
@property (readwrite,assign,nonatomic) uint16_t registerBC;
@property (readwrite,assign,nonatomic) uint16_t registerBCPrime;
@property (readwrite,assign,nonatomic) uint16_t registerDE;
@property (readwrite,assign,nonatomic) uint16_t registerDEPrime;
@property (readwrite,assign,nonatomic) uint16_t registerHL;
@property (readwrite,assign,nonatomic) uint16_t registerHLPrime;
@property (readwrite,assign,nonatomic) uint16_t registerIX;
@property (readwrite,assign,nonatomic) uint16_t registerIY;

@property (readwrite,assign,nonatomic) BOOL flagZ;
@property (readwrite,assign,nonatomic) BOOL flagC;
@property (readwrite,assign,nonatomic) BOOL flagS;
@property (readwrite,assign,nonatomic) BOOL flagPV;
@property (readwrite,assign,nonatomic) BOOL flagHC;
@property (readwrite,assign,nonatomic) BOOL flagN;

@property (readwrite,assign,nonatomic) BOOL CPUHalt;
@property (readwrite,assign,nonatomic) uint8_t CPUBus;
@property (readwrite,assign,nonatomic) uint32_t CPUFrequency;

@property (readwrite,assign,nonatomic) BOOL memoryMapBank0RamOrFlash;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank0Readonly;
@property (readwrite,assign,nonatomic) uint8_t memoryMapBank0Page;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank1RamOrFlash;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank1Readonly;
@property (readwrite,assign,nonatomic) uint8_t memoryMapBank1Page;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank2RamOrFlash;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank2Readonly;
@property (readwrite,assign,nonatomic) uint8_t memoryMapBank2Page;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank3RamOrFlash;
@property (readwrite,assign,nonatomic) BOOL memoryMapBank3Readonly;
@property (readwrite,assign,nonatomic) uint8_t memoryMapBank3Page;

@property (readwrite,assign,nonatomic) BOOL interruptsIFF1;
@property (readonly,nonatomic) double interruptsNextTimer1;
@property (readonly,nonatomic) double interruptsTimer1Duration;
@property (readwrite,assign,nonatomic) BOOL interruptsIFF2;
@property (readonly,nonatomic) double interruptsNextTimer2;
@property (readonly,nonatomic) double interruptsTimer2Duration;

@property (readwrite,assign,nonatomic) BOOL displayActive;
@property (readwrite,assign,nonatomic) uint32_t displayContrast;
@property (readwrite,assign,nonatomic) int32_t displayX;
@property (readwrite,assign,nonatomic) int32_t displayY;
@property (readwrite,assign,nonatomic) int32_t displayZ;
@property (readwrite,assign,nonatomic) LCD_CURSOR_MODE displayCursorMode;

+ (id)calculatorWithRomOrSavestateURL:(NSURL *)romOrSavestateURL error:(NSError **)outError;
- (id)initWithRomOrSavestateURL:(NSURL *)romOrSavestateURL error:(NSError **)outError;

- (BOOL)loadRomOrSavestateAtURL:(NSURL *)romOrSavestateURL error:(NSError **)outError;
- (void)reloadLastRomOrSavestate;

- (void)step;
- (void)stepOut;
- (void)stepOver;

@end
