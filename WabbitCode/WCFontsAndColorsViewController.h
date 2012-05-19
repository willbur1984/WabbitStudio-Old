//
//  WCFontsAndColorsViewController.h
//  WabbitEdit
//
//  Created by William Towe on 12/27/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JAViewController.h"
#import "RSPreferencesModule.h"
#import "RSUserDefaultsProvider.h"
#import "RSTableViewDelegate.h"

extern NSString *const WCFontsAndColorsCurrentThemeIdentifierKey;
extern NSString *const WCFontsAndColorsUserThemeIdentifiersKey;

@interface WCFontsAndColorsViewController : JAViewController <RSPreferencesModule,RSUserDefaultsProvider,RSTableViewDelegate,NSWindowDelegate,NSMenuDelegate>
@property (readwrite,assign,nonatomic) IBOutlet NSView *initialFirstResponder;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *themesArrayController;
@property (readwrite,assign,nonatomic) IBOutlet NSArrayController *pairsArrayController;
@property (readwrite,assign,nonatomic) IBOutlet RSTableView *themesTableView;
@property (readwrite,assign,nonatomic) IBOutlet NSTableView *pairsTableView;

- (IBAction)chooseFont:(id)sender;
- (IBAction)deleteTheme:(id)sender;
- (IBAction)duplicateTheme:(id)sender;
@end
