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
#import "WCBuildTarget.h"
#import "NSTextView+WCExtensions.h"
#import "NSAttributedString+RSExtensions.h"

static NSDateFormatter *dateFormatter;
static NSDateFormatter *timeFormatter;
static NSDictionary *normalAttributes;
static NSDictionary *boldAttributes;

@interface WCConsoleViewController ()
@property (assign,nonatomic) IBOutlet WCConsoleTextView *textView;
@property (readwrite,assign,nonatomic) IBOutlet NSView *gradientBarView;
@property (readwrite,assign,nonatomic) IBOutlet NSButton *clearButton;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@end

@implementation WCConsoleViewController
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        
        [timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        normalAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:13.0],NSFontAttributeName, nil];
        boldAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0],NSFontAttributeName, nil];
    });
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willBeginBuilding:) name:WCBuildControllerWillBeginBuildingNotification object:projectDocument.buildController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didFinishBuilding:) name:WCBuildControllerDidFinishBuildingNotification object:projectDocument.buildController];
    
    return self;
}

- (IBAction)clearConsole:(id)sender; {
    [self.textView.textStorage deleteCharactersInRange:NSMakeRange(0, self.textView.textStorage.length)];
}

@synthesize textView=_textView;
@synthesize gradientBarView=_gradientBarView;
@synthesize clearButton=_clearButton;

@synthesize projectDocument=_projectDocument;

- (void)_willBeginBuilding:(NSNotification *)note {
    NSDate *currentDate = [NSDate date];
    WCBuildTarget *buildTarget = self.projectDocument.activeBuildTarget;
    
    [self.textView WC_appendAttributedString:[NSAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@"Building target \"%@\" on %@ at %@\u2026\n", @"build target name and build date with ellipsis"),buildTarget.name,[dateFormatter stringFromDate:currentDate],[timeFormatter stringFromDate:currentDate]] attributes:boldAttributes]];
}

- (void)_didFinishBuilding:(NSNotification *)note {
    NSString *output = [self.projectDocument.buildController outputCopy];
    
    [self.textView WC_appendAttributedString:[NSAttributedString RS_attributedStringWithString:output attributes:normalAttributes]];
    
    WCBuildTarget *buildTarget = self.projectDocument.activeBuildTarget;
    WCBuildController *buildController = self.projectDocument.buildController;
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@"Build of target \"%@\" ", @"build target name"),buildTarget.name] attributes:boldAttributes];
    
    if (buildController.totalErrors && buildController.totalWarnings) {
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:NSLocalizedString(@"Failed", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[boldAttributes objectForKey:NSFontAttributeName],NSFontAttributeName,[NSColor colorWithCalibratedRed:0.75 green:0 blue:0 alpha:1.0],NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:@", " attributes:boldAttributes]];
        
        NSTextAttachment *attachment = [[[NSTextAttachment alloc] init] autorelease];
        NSTextAttachmentCell *attachmentCell = [[[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:@"Error"]] autorelease];
        
        [attachment setAttachmentCell:attachmentCell];
        
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@" %lu error(s), ", @"total errors format"),buildController.totalErrors] attributes:boldAttributes]];
        
        attachment = [[[NSTextAttachment alloc] init] autorelease];
        attachmentCell = [[[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:@"Warning"]] autorelease];
        
        [attachment setAttachmentCell:attachmentCell];
        
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@" %lu warnings(s)", @"total warnings format"),buildController.totalWarnings] attributes:boldAttributes]];
    }
    else if (buildController.totalErrors) {
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:NSLocalizedString(@"Failed", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[boldAttributes objectForKey:NSFontAttributeName],NSFontAttributeName,[NSColor colorWithCalibratedRed:0.75 green:0 blue:0 alpha:1.0],NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:@", " attributes:boldAttributes]];
        
        NSTextAttachment *attachment = [[[NSTextAttachment alloc] init] autorelease];
        NSTextAttachmentCell *attachmentCell = [[[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:@"Error"]] autorelease];
        
        [attachment setAttachmentCell:attachmentCell];
        
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@" %lu error(s)", @"total errors format"),buildController.totalErrors] attributes:boldAttributes]];
    }
    else if (buildController.totalWarnings) {
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:NSLocalizedString(@"Succeeded", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[boldAttributes objectForKey:NSFontAttributeName],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName, nil]]];
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:@", " attributes:boldAttributes]];
        
        NSTextAttachment *attachment = [[[NSTextAttachment alloc] init] autorelease];
        NSTextAttachmentCell *attachmentCell = [[[NSTextAttachmentCell alloc] initImageCell:[NSImage imageNamed:@"Warning"]] autorelease];
        
        [attachment setAttachmentCell:attachmentCell];
        
        [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:[NSString stringWithFormat:NSLocalizedString(@" %lu warning(s)", @"total errors format"),buildController.totalWarnings] attributes:boldAttributes]];
    }
    else {
        [attributedString appendAttributedString:[NSAttributedString RS_attributedStringWithString:NSLocalizedString(@"Succeeded", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[boldAttributes objectForKey:NSFontAttributeName],NSFontAttributeName,[NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1.0],NSForegroundColorAttributeName, nil]]];
    }
    
    [self.textView WC_appendAttributedString:attributedString];
    [self.textView WC_appendNewline];
    [self.textView WC_appendNewline];
}

@end
