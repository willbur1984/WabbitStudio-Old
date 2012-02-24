//
//  RSCalculator.m
//  WabbitStudio
//
//  Created by William Towe on 2/21/12.
//  Copyright (c) 2012 Revolution Software. All rights reserved.
//

#import "RSCalculator.h"
#include "alu.h"
#include "ti_stdint.h"

NSString *const RSCalculatorRomUTI = @"org.revsoft.wabbitemu.rom";
NSString *const RSCalculatorSavestateUTI = @"org.revsoft.wabbitemu.savestate";
NSString *const RSCalculatorProgramUTI = @"org.revsoft.wabbitemu.program";
NSString *const RSCalculatorApplicationUTI = @"org.revsoft.wabbitemu.application";
NSString *const RSCalculatorGroupFileUTI = @"org.revsoft.wabbitemu.group";
NSString *const RSCalculatorPictureFileUTI = @"org.revsoft.wabbitemu.picture";

NSString *const RSCalculatorLabelFileUTI = @"org.revsoft.wabbitemu.label";

NSString *const RSCalculatorWillLoadRomOrSavestateNotification = @"RSCalculatorWillLoadRomOrSavestateNotification";
NSString *const RSCalculatorDidLoadRomOrSavestateNotification = @"RSCalculatorDidLoadRomOrSavestateNotification";

NSString *const RSCalculatorErrorDomain = @"org.revsoft.calculator.error";
const NSInteger RSCalculatorErrorCodeUnrecognizedRomOrSavestate = 1001;
const NSInteger RSCalculatorErrorCodeMaximumNumberOfCalculators = 1002;

@interface RSCalculator ()
@property (readwrite,assign,nonatomic,getter = isLoading) BOOL loading;
@property (readwrite,copy,nonatomic) NSURL *lastLoadedURL;
@end

@implementation RSCalculator
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
#ifdef DEBUG
	NSLog(@"%@ called in %@",NSStringFromSelector(_cmd),[self className]);
#endif
	_delegate = nil;
	[_lastLoadedURL release];
	calc_slot_free(_calculator);
	[super dealloc];
}

- (id)init {
	return [self initWithRomOrSavestateURL:nil error:NULL];
}
#pragma mark *** Public Methods ***
+ (id)calculatorWithRomOrSavestateURL:(NSURL *)romOrSavestateURL error:(NSError **)outError; {
	return [[[[self class] alloc] initWithRomOrSavestateURL:romOrSavestateURL error:outError] autorelease];
}
- (id)initWithRomOrSavestateURL:(NSURL *)romOrSavestateURL error:(NSError **)outError; {
	if (!(self = [super init]))
		return nil;
	
	LPCALC calculator = calc_slot_new();
	if (!calculator) {
		if (outError) {
			*outError = [NSError errorWithDomain:RSCalculatorErrorDomain code:RSCalculatorErrorCodeMaximumNumberOfCalculators userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Maximum Number of Calculators Reached", @"Maximum Number of Calculators Reached"),NSLocalizedDescriptionKey,[NSString stringWithFormat:NSLocalizedString(@"The maximum number of calculators (%d) have already been opened. Please close some calculators and try again.", @"maximum number of calculators recovery suggestion error format string"),MAX_CALCS],NSLocalizedRecoverySuggestionErrorKey, nil]];
		}
		
		[self release];
		return nil;
	}
	
	_calculator = calculator;
	
	if (romOrSavestateURL && ![self loadRomOrSavestateAtURL:romOrSavestateURL error:outError]) {
		[self release];
		return nil;
	}
	
	return self;
}

- (BOOL)loadRomOrSavestateAtURL:(NSURL *)romOrSavestateURL error:(NSError **)outError; {
	[self setRunning:NO];
	[self setLoading:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RSCalculatorWillLoadRomOrSavestateNotification object:self];
	
	BOOL loaded = rom_load([self calculator], [[romOrSavestateURL path] fileSystemRepresentation]);
	
	if (!loaded) {
		if (outError) {
			*outError = [NSError errorWithDomain:RSCalculatorErrorDomain code:RSCalculatorErrorCodeUnrecognizedRomOrSavestate userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Rom or Savestate Unrecognized", @"Rom or Savestate Unrecognized"),NSLocalizedDescriptionKey,[NSString stringWithFormat:NSLocalizedString(@"The rom or savestate located at %@ was not recognized.", @"rom or savestate unrecognized recovery suggestion error format string"),[[romOrSavestateURL path] stringByAbbreviatingWithTildeInPath]],NSLocalizedRecoverySuggestionErrorKey, nil]];
		}
		
		[self setLoading:NO];
		return NO;
	}
	
	calc_turn_on([self calculator]);
	
	[self setLastLoadedURL:romOrSavestateURL];
	[self setRunning:YES];
	[self setLoading:NO];
	
	if ([[self delegate] respondsToSelector:@selector(calculator:didLoadRomOrSavestateURL:)])
		[[self delegate] calculator:self didLoadRomOrSavestateURL:romOrSavestateURL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RSCalculatorDidLoadRomOrSavestateNotification object:self];
	
	return YES;
}
- (void)reloadLastRomOrSavestate {
	[self loadRomOrSavestateAtURL:[self lastLoadedURL] error:NULL];
}

- (void)step; {
	
}
- (void)stepOut; {
	
}
- (void)stepOver; {
	
}
#pragma mark Properties
@synthesize delegate=_delegate;
@synthesize calculator=_calculator;
@dynamic loading;
- (BOOL)isLoading {
	return _calculatorFlags.loading;
}
- (void)setLoading:(BOOL)loading {
	_calculatorFlags.loading = loading;
}
@dynamic debugging;
- (BOOL)isDebugging {
	return _calculatorFlags.debugging;
}
- (void)setDebugging:(BOOL)debugging {
	_calculatorFlags.debugging = debugging;
}
@dynamic active;
- (BOOL)isActive {
	return ([self calculator] && [self calculator]->active);
}
- (void)setActive:(BOOL)active {
	[self calculator]->active = active;
}
@dynamic running;
- (BOOL)isRunning {
	return ([self calculator] && [self calculator]->running);
}
- (void)setRunning:(BOOL)running {
	[self calculator]->running = running;
}
@dynamic model;
- (RSCalculatorModel)model {
	if ([self isActive])
		return [self calculator]->model;
	return defaultValue;
}
@dynamic modelString;
- (NSString *)modelString {
	switch ([self model]) {
		case RSCalculatorModelTI_73:
			return NSLocalizedString(@"TI-73", @"TI-73");
		case RSCalculatorModelTI_81:
			return NSLocalizedString(@"TI-81", @"TI-81");
		case RSCalculatorModelTI_82:
			return NSLocalizedString(@"TI-82", @"TI-82");
		case RSCalculatorModelTI_83:
			return NSLocalizedString(@"TI-83", @"TI-83");
		case RSCalculatorModelTI_83P:
			return NSLocalizedString(@"TI-83+", @"TI-83+");
		case RSCalculatorModelTI_83PSE:
			return NSLocalizedString(@"TI-83+SE", @"TI-83+SE");
		case RSCalculatorModelTI_84P:
			return NSLocalizedString(@"TI-84+", @"TI-84+");
		case RSCalculatorModelTI_84PSE:
			return NSLocalizedString(@"TI-84+SE", @"TI-84+SE");
		case RSCalculatorModelTI_85:
			return NSLocalizedString(@"TI-85", @"TI-85");
		case RSCalculatorModelTI_86:
			return NSLocalizedString(@"TI-86", @"TI-86");
		default:
			return nil;
	}
}
@dynamic skinImage;
- (NSImage *)skinImage {
	switch ([self model]) {
		case RSCalculatorModelTI_73:
			return [NSImage imageNamed:@"ti-73"];
		case RSCalculatorModelTI_81:
			return [NSImage imageNamed:@"ti-81"];
		case RSCalculatorModelTI_82:
			return [NSImage imageNamed:@"ti-82"];
		case RSCalculatorModelTI_83:
			return [NSImage imageNamed:@"ti-83"];
		case RSCalculatorModelTI_83P:
			return [NSImage imageNamed:@"ti-83+"];
		case RSCalculatorModelTI_83PSE:
			return [NSImage imageNamed:@"ti-83+se"];
		case RSCalculatorModelTI_84P:
			return [NSImage imageNamed:@"ti-84+"];
		case RSCalculatorModelTI_84PSE:
			return [NSImage imageNamed:@"ti-84+se"];
		case RSCalculatorModelTI_85:
			return [NSImage imageNamed:@"ti-85"];
		case RSCalculatorModelTI_86:
			return [NSImage imageNamed:@"ti-86"];
		default:
			return nil;
	}
}
@dynamic keymapImage;
- (NSImage *)keymapImage {
	switch ([self model]) {
		case RSCalculatorModelTI_73:
		case RSCalculatorModelTI_83P:
		case RSCalculatorModelTI_83PSE:
			return [NSImage imageNamed:@"ti-83+keymap"];
		case RSCalculatorModelTI_81:
		case RSCalculatorModelTI_82:
			return [NSImage imageNamed:@"ti-82keymap"];
		case RSCalculatorModelTI_83:
			return [NSImage imageNamed:@"ti-83keymap"];
		case RSCalculatorModelTI_84P:
		case RSCalculatorModelTI_84PSE:
			return [NSImage imageNamed:@"ti-84+sekeymap"];
		case RSCalculatorModelTI_85:
			return [NSImage imageNamed:@"ti-85keymap"];
		case RSCalculatorModelTI_86:
			return [NSImage imageNamed:@"ti-86keymap"];
		default:
			return nil;
	}
}
#pragma mark Registers
static const uint32_t defaultValue = 0;
@dynamic programCounter;
- (uint16_t)programCounter {
	if ([self isActive])
		return [self calculator]->cpu.pc;
	return defaultValue;
}
- (void)setProgramCounter:(uint16_t)programCounter {
	if ([self isActive])
		[self calculator]->cpu.pc = programCounter;
}
@dynamic stackPointer;
- (uint16_t)stackPointer {
	if ([self isActive])
		return [self calculator]->cpu.sp;
	return defaultValue;
}
- (void)setStackPointer:(uint16_t)stackPointer {
	if ([self isActive])
		[self calculator]->cpu.sp = stackPointer;
}
@dynamic registerAF;
- (uint16_t)registerAF {
	if ([self isActive])
		return [self calculator]->cpu.af;
	return defaultValue;
}
- (void)setRegisterAF:(uint16_t)registerAF {
	if ([self isActive])
		[self calculator]->cpu.af = registerAF;
}
@dynamic registerAFPrime;
- (uint16_t)registerAFPrime {
	if ([self isActive])
		return [self calculator]->cpu.afp;
	return defaultValue;
}
- (void)setRegisterAFPrime:(uint16_t)registerAFPrime {
	if ([self isActive])
		[self calculator]->cpu.afp = registerAFPrime;
}
@dynamic registerBC;
- (uint16_t)registerBC {
	if ([self isActive])
		return [self calculator]->cpu.bc;
	return defaultValue;
}
- (void)setRegisterBC:(uint16_t)registerBC {
	if ([self isActive])
		[self calculator]->cpu.bc = registerBC;
}
@dynamic registerBCPrime;
- (uint16_t)registerBCPrime {
	if ([self isActive])
		return [self calculator]->cpu.bcp;
	return defaultValue;
}
- (void)setRegisterBCPrime:(uint16_t)registerBCPrime {
	if ([self isActive])
		[self calculator]->cpu.bcp = registerBCPrime;
}
@dynamic registerDE;
- (uint16_t)registerDE {
	if ([self isActive])
		return [self calculator]->cpu.de;
	return defaultValue;
}
- (void)setRegisterDE:(uint16_t)registerDE {
	if ([self isActive])
		[self calculator]->cpu.de = registerDE;
}
@dynamic registerDEPrime;
- (uint16_t)registerDEPrime {
	if ([self isActive])
		return [self calculator]->cpu.dep;
	return defaultValue;
}
- (void)setRegisterDEPrime:(uint16_t)registerDEPrime {
	if ([self isActive])
		[self calculator]->cpu.dep = registerDEPrime;
}
@dynamic registerHL;
- (uint16_t)registerHL {
	if ([self isActive])
		return [self calculator]->cpu.hl;
	return defaultValue;
}
- (void)setRegisterHL:(uint16_t)registerHL {
	if ([self isActive])
		[self calculator]->cpu.hl = registerHL;
}
@dynamic registerHLPrime;
- (uint16_t)registerHLPrime {
	if ([self isActive])
		return [self calculator]->cpu.hlp;
	return defaultValue;
}
- (void)setRegisterHLPrime:(uint16_t)registerHLPrime {
	if ([self isActive])
		[self calculator]->cpu.hlp = registerHLPrime;
}
@dynamic registerIX;
- (uint16_t)registerIX {
	if ([self isActive])
		return [self calculator]->cpu.ix;
	return defaultValue;
}
- (void)setRegisterIX:(uint16_t)registerIX {
	if ([self isActive])
		[self calculator]->cpu.ix = registerIX;
}
@dynamic registerIY;
- (uint16_t)registerIY {
	if ([self isActive])
		return [self calculator]->cpu.iy;
	return defaultValue;
}
- (void)setRegisterIY:(uint16_t)registerIY {
	if ([self isActive])
		[self calculator]->cpu.iy = registerIY;
}
#pragma mark Flags
@dynamic flagZ;
- (BOOL)flagZ {
	return ([self isActive] && ([self calculator]->cpu.f & ZERO_MASK) != 0);
}
- (void)setFlagZ:(BOOL)flagZ {
	if ([self isActive])
		[self calculator]->cpu.f ^= ZERO_MASK;
}
@dynamic flagC;
- (BOOL)flagC {
	return ([self isActive] && ([self calculator]->cpu.f & CARRY_MASK) != 0);
}
- (void)setFlagC:(BOOL)flagC {
	if ([self isActive])
		[self calculator]->cpu.f ^= CARRY_MASK;
}
@dynamic flagS;
- (BOOL)flagS {
	return ([self isActive] && ([self calculator]->cpu.f & SIGN_MASK) != 0);
}
- (void)setFlagS:(BOOL)flagS {
	if ([self isActive])
		[self calculator]->cpu.f ^= SIGN_MASK;
}
@dynamic flagPV;
- (BOOL)flagPV {
	return ([self isActive] && ([self calculator]->cpu.f & PV_MASK) != 0);
}
- (void)setFlagPV:(BOOL)flagPV {
	if ([self isActive])
		[self calculator]->cpu.f ^= PV_MASK;
}
@dynamic flagHC;
- (BOOL)flagHC {
	return ([self isActive] && ([self calculator]->cpu.f & HC_MASK) != 0);
}
- (void)setFlagHC:(BOOL)flagHC {
	if ([self isActive])
		[self calculator]->cpu.f ^= HC_MASK;
}
@dynamic flagN;
- (BOOL)flagN {
	return ([self isActive] && ([self calculator]->cpu.f & N_MASK) != 0);
}
- (void)setFlagN:(BOOL)flagN {
	if ([self isActive])
		[self calculator]->cpu.f ^= N_MASK;
}
#pragma mark CPU
@dynamic CPUHalt;
- (BOOL)CPUHalt {
	return ([self isActive] && [self calculator]->cpu.halt);
}
- (void)setCPUHalt:(BOOL)CPUHalt {
	if ([self isActive])
		[self calculator]->cpu.halt = CPUHalt;
}
@dynamic CPUBus;
- (uint8_t)CPUBus {
	if ([self isActive])
		return [self calculator]->cpu.bus;
	return defaultValue;
}
- (void)setCPUBus:(uint8_t)CPUBus {
	if ([self isActive])
		[self calculator]->cpu.bus = CPUBus;
}
@dynamic CPUFrequency;
- (uint32_t)CPUFrequency {
	if ([self isActive])
		return [self calculator]->timer_c.freq;
	return defaultValue;
}
- (void)setCPUFrequency:(uint32_t)CPUFrequency {
	if ([self isActive])
		[self calculator]->timer_c.freq = CPUFrequency;
}
#pragma mark Memory Map
@dynamic memoryMapBank0Page;
- (uint8_t)memoryMapBank0Page {
	if ([self isActive])
		return [self calculator]->mem_c.banks[0].page;
	return defaultValue;
}
- (void)setMemoryMapBank0Page:(uint8_t)memoryMapBank0Page {
	if ([self isActive])
		[self calculator]->mem_c.banks[0].page = memoryMapBank0Page;
}
@dynamic memoryMapBank0RamOrFlash;
- (BOOL)memoryMapBank0RamOrFlash {
	return ([self isActive] && [self calculator]->mem_c.banks[0].ram);
}
- (void)setMemoryMapBank0RamOrFlash:(BOOL)memoryMapBank0RamOrFlash {
	if ([self isActive])
		[self calculator]->mem_c.banks[0].ram = memoryMapBank0RamOrFlash;
}
@dynamic memoryMapBank0Readonly;
- (BOOL)memoryMapBank0Readonly {
	return ([self isActive] && [self calculator]->mem_c.banks[0].read_only);
}
- (void)setMemoryMapBank0Readonly:(BOOL)memoryMapBank0Readonly {
	if ([self isActive])
		[self calculator]->mem_c.banks[0].read_only = memoryMapBank0Readonly;
}
@dynamic memoryMapBank1Page;
- (uint8_t)memoryMapBank1Page {
	if ([self isActive])
		return [self calculator]->mem_c.banks[1].page;
	return defaultValue;
}
- (void)setMemoryMapBank1Page:(uint8_t)memoryMapBank1Page {
	if ([self isActive])
		[self calculator]->mem_c.banks[1].page = memoryMapBank1Page;
}
@dynamic memoryMapBank1RamOrFlash;
- (BOOL)memoryMapBank1RamOrFlash {
	return ([self isActive] && [self calculator]->mem_c.banks[1].ram);
}
- (void)setMemoryMapBank1RamOrFlash:(BOOL)memoryMapBank1RamOrFlash {
	if ([self isActive])
		[self calculator]->mem_c.banks[1].ram = memoryMapBank1RamOrFlash;
}
@dynamic memoryMapBank1Readonly;
- (BOOL)memoryMapBank1Readonly {
	return ([self isActive] && [self calculator]->mem_c.banks[1].read_only);
}
- (void)setMemoryMapBank1Readonly:(BOOL)memoryMapBank1Readonly {
	if ([self isActive])
		[self calculator]->mem_c.banks[1].read_only = memoryMapBank1Readonly;
}
@dynamic memoryMapBank2Page;
- (uint8_t)memoryMapBank2Page {
	if ([self isActive])
		return [self calculator]->mem_c.banks[2].page;
	return defaultValue;
}
- (void)setMemoryMapBank2Page:(uint8_t)memoryMapBank2Page {
	if ([self isActive])
		[self calculator]->mem_c.banks[2].page = memoryMapBank2Page;
}
@dynamic memoryMapBank2RamOrFlash;
- (BOOL)memoryMapBank2RamOrFlash {
	return ([self isActive] && [self calculator]->mem_c.banks[2].ram);
}
- (void)setMemoryMapBank2RamOrFlash:(BOOL)memoryMapBank2RamOrFlash {
	if ([self isActive])
		[self calculator]->mem_c.banks[2].ram = memoryMapBank2RamOrFlash;
}
@dynamic memoryMapBank2Readonly;
- (BOOL)memoryMapBank2Readonly {
	return ([self isActive] && [self calculator]->mem_c.banks[2].read_only);
}
- (void)setMemoryMapBank2Readonly:(BOOL)memoryMapBank2Readonly {
	if ([self isActive])
		[self calculator]->mem_c.banks[2].read_only = memoryMapBank2Readonly;
}
@dynamic memoryMapBank3Page;
- (uint8_t)memoryMapBank3Page {
	if ([self isActive])
		return [self calculator]->mem_c.banks[3].page;
	return defaultValue;
}
- (void)setMemoryMapBank3Page:(uint8_t)memoryMapBank3Page {
	if ([self isActive])
		[self calculator]->mem_c.banks[3].page = memoryMapBank3Page;
}
@dynamic memoryMapBank3RamOrFlash;
- (BOOL)memoryMapBank3RamOrFlash {
	return ([self isActive] && [self calculator]->mem_c.banks[3].ram);
}
- (void)setMemoryMapBank3RamOrFlash:(BOOL)memoryMapBank3RamOrFlash {
	if ([self isActive])
		[self calculator]->mem_c.banks[3].ram = memoryMapBank3RamOrFlash;
}
@dynamic memoryMapBank3Readonly;
- (BOOL)memoryMapBank3Readonly {
	return ([self isActive] && [self calculator]->mem_c.banks[3].read_only);
}
- (void)setMemoryMapBank3Readonly:(BOOL)memoryMapBank3Readonly {
	if ([self isActive])
		[self calculator]->mem_c.banks[3].read_only = memoryMapBank3Readonly;
}
#pragma mark Interrupts
@dynamic interruptsIFF1;
- (BOOL)interruptsIFF1 {
	return ([self isActive] && [self calculator]->cpu.iff1);
}
- (void)setInterruptsIFF1:(BOOL)interruptsIFF1 {
	if ([self isActive])
		[self calculator]->cpu.iff1 = interruptsIFF1;
}
@dynamic interruptsIFF2;
- (BOOL)interruptsIFF2 {
	return ([self isActive] && [self calculator]->cpu.iff2);
}
- (void)setInterruptsIFF2:(BOOL)interruptsIFF2 {
	if ([self isActive])
		[self calculator]->cpu.iff2 = interruptsIFF2;
}
@dynamic interruptsNextTimer1;
- (double)interruptsNextTimer1 {
	if ([self isActive])
		return ([self calculator]->timer_c.elapsed - [self calculator]->cpu.pio.stdint->lastchk1);
	return defaultValue;
}
@dynamic interruptsNextTimer2;
- (double)interruptsNextTimer2 {
	if ([self isActive])
		return ([self calculator]->timer_c.elapsed - [self calculator]->cpu.pio.stdint->lastchk2);
	return defaultValue;
}
@dynamic interruptsTimer1Duration;
- (double)interruptsTimer1Duration {
	if ([self isActive])
		return [self calculator]->cpu.pio.stdint->timermax1;
	return defaultValue;
}
@dynamic interruptsTimer2Duration;
- (double)interruptsTimer2Duration {
	if ([self isActive])
		return [self calculator]->cpu.pio.stdint->timermax2;
	return defaultValue;
}
#pragma mark Display
@dynamic displayActive;
- (BOOL)displayActive {
	return ([self isActive] && [self calculator]->cpu.pio.lcd->active);
}
- (void)setDisplayActive:(BOOL)displayActive {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->active = displayActive;
}
@dynamic displayContrast;
- (uint32_t)displayContrast {
	if ([self isActive])
		return [self calculator]->cpu.pio.lcd->contrast;
	return defaultValue;
}
- (void)setDisplayContrast:(uint32_t)displayContrast {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->contrast = displayContrast;
}
@dynamic displayX;
- (int32_t)displayX {
	if ([self isActive])
		return [self calculator]->cpu.pio.lcd->x;
	return defaultValue;
}
- (void)setDisplayX:(int32_t)displayX {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->x = displayX;
}
@dynamic displayY;
- (int32_t)displayY {
	if ([self isActive])
		return [self calculator]->cpu.pio.lcd->y;
	return defaultValue;
}
- (void)setDisplayY:(int32_t)displayY {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->y = displayY;
}
@dynamic displayZ;
- (int32_t)displayZ {
	if ([self isActive])
		return [self calculator]->cpu.pio.lcd->z;
	return defaultValue;
}
- (void)setDisplayZ:(int32_t)displayZ {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->z = displayZ;
}
@dynamic displayCursorMode;
- (LCD_CURSOR_MODE)displayCursorMode {
	if ([self isActive])
		return [self calculator]->cpu.pio.lcd->cursor_mode;
	return defaultValue;
}
- (void)setDisplayCursorMode:(LCD_CURSOR_MODE)displayCursorMode {
	if ([self isActive])
		[self calculator]->cpu.pio.lcd->cursor_mode = displayCursorMode;
}
#pragma mark *** Private Methods ***

#pragma mark Properties
@synthesize lastLoadedURL=_lastLoadedURL;
@end
