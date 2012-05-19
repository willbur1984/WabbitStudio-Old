//
//  WCConsoleViewController.m
//  WabbitStudio
//
//  Created by William Towe on 5/19/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCConsoleViewController.h"
#import "WCProjectDocument.h"
#import "WCBuildController.h"
#import "WCConsoleTextView.h"

@interface WCConsoleViewController ()
@property (readwrite,assign,nonatomic) IBOutlet WCConsoleTextView *textView;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@end

@implementation WCConsoleViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _projectDocument = nil;
    [super dealloc];
}

- (NSString *)nibName {
    return @"WCConsoleView";
}

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
    if (!(self = [super initWithNibName:self.nibName bundle:nil]))
        return nil;
    
    _projectDocument = projectDocument;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:projectDocument.buildController];
    
    return self;
}

@synthesize textView=_textView;

@synthesize projectDocument=_projectDocument;

- (void)_didFinishBuilding:(NSNotification *)note {
    NSString *output = [self.projectDocument.buildController outputCopy];
    
    [self.textView replaceCharactersInRange:NSMakeRange(self.textView.string.length, 0) withString:output];
    [self.textView replaceCharactersInRange:NSMakeRange(self.textView.string.length, 0) withString:@"\n"];
}

@end
