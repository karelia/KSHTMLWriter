//
//  KSXMLWriter.h
//  Sandvox
//
//  Created by Mike on 19/05/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSWriter.h"


@interface KSXMLWriter : NSObject <KSWriter>
{
  @private
    id <KSWriter> _writer;
    
    NSMutableArray  *_openElements;
    BOOL            _elementIsEmpty;
    NSUInteger      _inlineWritingLevel;    // the number of open elements at which inline writing began
    
    NSInteger       _indentation;
}

#pragma mark Creating an XML Writer
- (id)initWithOutputWriter:(id <KSWriter>)stream; // designated initializer
- (id)init; // calls -initWithOutputWriter with nil. Handy for iteration & deriving info, but not a lot else


#pragma mark Writer Status
- (void)close;  // calls -flush, then releases most ivars such as _writer
- (void)flush;  // if there's anything waiting to be lazily written, forces it to write now. For subclasses to implement


#pragma mark Document
- (void)startDocument:(NSString *)DTD;  // at present, expect DTD to be complete tag


#pragma mark Elements

// Calls -openTag:. Then -writeAttribute:value: for each entry in the dictionary. Finishes with -didStartElement. Others are variations on the design for convenience
- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
- (void)startElement:(NSString *)name attribute:(NSString *)attr value:(NSString *)attrValue;

//  </tagName>
//  The start tag must have been written by -openTag: or one of the higher-level methods that calls through to it, otherwise won't know what to write
- (void)endElement;


#pragma mark Basic Writing

//  Escapes the string and calls -writeString:. NOT intended for writing text-like strings e.g. element attributed
- (void)writeText:(NSString *)string;

//  Writes a newline character and the tabs to match -indentationLevel. Nornally newlines are automatically written for you; call this if you need an extra one.
- (void)startNewline;


#pragma mark Comments
- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
- (void)openComment;
- (void)closeComment;


#pragma mark Indentation
// Setting the indentation level does not write to the context in any way. It is up to methods that actually do some writing to respect the indent level. e.g. starting a new line should indent that line to match.
@property(nonatomic) NSInteger indentationLevel;
- (void)increaseIndentationLevel;
- (void)decreaseIndentationLevel;


#pragma mark Elements Stack
// XMLWriter maintains a stack of the open elements so it knows how to end them

- (NSUInteger)openElementsCount;
- (BOOL)hasOpenElementWithTagName:(NSString *)tagName;

- (NSString *)topElement;

// Element writing methods automatically call these, but you can also manipulate the stack manually.
- (void)pushElement:(NSString *)tagName;
- (void)popElement;


#pragma mark Element Primitives

//  <tagName
//  Records the tag using -pushElement:. You must call -writeEndTag or -popElement later.
- (void)openTag:(NSString *)element;
- (void)openTag:(NSString *)element writeInline:(BOOL)writeInline;

//   attribute="value"
- (void)writeAttribute:(NSString *)attribute
                 value:(NSString *)value;

//  Starts tracking -writeString: calls to see if element is empty
- (void)didStartElement;

//  >
//  Then increases indentation level
- (void)closeStartTag;

//   />
- (void)closeEmptyElementTag;             

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack

- (BOOL)elementCanBeEmpty:(NSString *)tagName;  // YES for everything in pure XML


#pragma mark Inline Writing
- (BOOL)isWritingInline;
- (void)startWritingInline;
- (void)stopWritingInline;
- (BOOL)canWriteElementInline:(NSString *)tagName;


#pragma mark Primitive

- (void)writeString:(NSString *)string; // calls -writeString: on our string stream. Override to customize raw writing


@end
