//
//  KSXMLWriter.h
//  Sandvox
//
//  Created by Mike on 19/05/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSForwardingWriter.h"


@interface KSXMLWriter : KSForwardingWriter
{
  @private
    NSMutableArray  *_openElements;
    NSMutableArray  *_attributes;
    BOOL            _elementIsEmpty;
    NSUInteger      _inlineWritingLevel;    // the number of open elements at which inline writing began
    
    NSInteger       _indentation;
}

#pragma mark Writer Status
- (void)close;  // calls -flush, then releases most ivars such as _writer
- (void)flush;  // if there's anything waiting to be lazily written, forces it to write now. For subclasses to implement


#pragma mark Document
- (void)startDocument:(NSString *)DTD;  // at present, expect DTD to be complete tag


#pragma mark Text
//  Escapes the string and calls -writeString:. NOT intended for writing text-like strings e.g. element attributed
- (void)writeText:(NSString *)string;


#pragma mark Elements

// Convenience for writing <tag>text</tag>
- (void)writeElement:(NSString *)elementName text:(NSString *)text;

// These simple methods make up the bulk of element writing. You can start as many elements at a time as you like in order to nest them. Calling -endElement will automatically know the right close tag to write etc.
- (void)startElement:(NSString *)elementName;
- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
- (void)endElement;

/*  You can also gain finer-grained control over element attributes. KSXMLWriter maintains a list of attributes that will be applied when you *next* call one of the -startElement: methods. This has several advantages:
 *      - Attributes are written in exactly the order you specify
 *      - More efficient than building up a temporary dictionary object
 *      - Can sneak extra attributes in when using a convenience method (e.g. for HTML)
 */
- (void)addElementAttribute:(NSString *)attribute value:(NSString *)value;
- (NSDictionary *)elementAttributes;


#pragma mark Whitespace
//  Writes a newline character and the tabs to match -indentationLevel. Nornally newlines are automatically written for you; call this if you need an extra one.
- (void)startNewline;


#pragma mark Comments
- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
- (void)openComment;
- (void)closeComment;


#pragma mark CDATA
- (void)startCDATA;
- (void)endCDATA;


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
- (void)closeEmptyElementTag;             


#pragma mark Inline Writing
- (BOOL)isWritingInline;
- (void)startWritingInline;
- (void)stopWritingInline;
- (BOOL)canWriteElementInline:(NSString *)tagName;


@end
