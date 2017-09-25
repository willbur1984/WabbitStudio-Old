//
//  WCSymbolNavigatorViewController.h
//  WabbitStudio
//
//  Created by William Towe on 2/16/12.
//  Copyright (c) 2012 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JAViewController.h"
#import "WCNavigatorModule.h"

@class WCProjectDocument,WCSymbolFileContainer;

@interface WCSymbolNavigatorViewController : NSViewController <WCNavigatorModule> {
	__unsafe_unretained WCProjectDocument *_projectDocument;
	WCSymbolFileContainer *_symbolFileContainer;
	WCSymbolFileContainer *_filteredSymbolFileContainer;
}
@property (readwrite,assign,nonatomic) IBOutlet NSTreeController *treeController;
@property (readwrite,assign,nonatomic) IBOutlet NSOutlineView *outlineView;
@property (readwrite,assign,nonatomic) IBOutlet NSSearchField *searchField;

@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (readonly,nonatomic) WCSymbolFileContainer *symbolFileContainer;

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument;

@end
